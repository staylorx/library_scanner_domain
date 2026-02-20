import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';

import '../hive/datasources/author_datasource.dart';
import '../models/author_model.dart';
import 'base_repository.dart';

/// Hive implementation of [AuthorRepository].
class AuthorRepositoryImpl extends HiveBaseRepository
    with Loggable
    implements AuthorRepository {
  final AuthorDatasource _authorDatasource;
  final AuthorIdRegistryService _idRegistryService;

  AuthorRepositoryImpl({
    required AuthorDatasource authorDatasource,
    required UnitOfWork<TransactionHandle> unitOfWork,
    required AuthorIdRegistryService idRegistryService,
    Logger? logger,
  }) : _authorDatasource = authorDatasource,
       _idRegistryService = idRegistryService,
       super(unitOfWork) {
    this.logger = logger;
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  @override
  TaskEither<Failure, List<Author>> getAll() =>
      _authorDatasource.getAllAuthors().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );

  @override
  TaskEither<Failure, Author> getById({required String id}) =>
      _authorDatasource.getAuthorById(id).flatMap(
        (model) => model != null
            ? TaskEither.right(model.toEntity())
            : TaskEither.left(NotFoundFailure('Author not found')),
      );

  @override
  TaskEither<Failure, Author> getAuthorByName({required String name}) =>
      _authorDatasource.getAuthorByName(name).flatMap(
        (model) => model != null
            ? TaskEither.right(model.toEntity())
            : TaskEither.left(NotFoundFailure('Author not found')),
      );

  @override
  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  }) {
    if (names.isEmpty) return TaskEither.right([]);
    return _authorDatasource
        .getAuthorsByNames(names)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  }) => _authorDatasource.getAuthorsByBusinessIdPair(authorIdPair).flatMap(
    (models) => models.isNotEmpty
        ? TaskEither.right(models.first.toEntity())
        : TaskEither.left(NotFoundFailure('Author not found')),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  @override
  TaskEither<Failure, Author> create({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final author =
        item.id.isNotEmpty ? item : item.copyWith(id: const Uuid().v4());
    final model = AuthorModel.fromEntity(author);
    final idPairs = AuthorIdPairs(pairs: author.businessIds);

    return runInTransaction(
      txn: txn,
      operation: (_) =>
          _idRegistryService.registerAuthorIdPairs(idPairs).flatMap(
            (_) => _authorDatasource.saveAuthor(model),
          ).map((_) => author),
    );
  }

  @override
  TaskEither<Failure, Author> update({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final model = AuthorModel.fromEntity(item);
    return getById(id: item.id).flatMap((oldAuthor) {
      final oldIdPairs = AuthorIdPairs(pairs: oldAuthor.businessIds);
      final newIdPairs = AuthorIdPairs(pairs: item.businessIds);
      return runInTransaction(
        txn: txn,
        operation: (_) =>
            _idRegistryService.unregisterAuthorIdPairs(oldIdPairs).flatMap(
              (_) => _idRegistryService.registerAuthorIdPairs(newIdPairs),
            ).flatMap((_) => _authorDatasource.saveAuthor(model)).map(
              (_) => item,
            ),
      );
    });
  }

  @override
  TaskEither<Failure, Unit> deleteById({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    return getById(id: item.id).flatMap((author) {
      final idPairs = AuthorIdPairs(pairs: author.businessIds);
      return runInTransaction(
        txn: txn,
        operation: (_) =>
            _idRegistryService.unregisterAuthorIdPairs(idPairs).flatMap(
              (_) => _authorDatasource.deleteAuthorWithCascade(author.id),
            ).map((_) => unit),
      );
    });
  }

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) =>
      runInTransaction(
        txn: txn,
        operation: (_) => _authorDatasource.deleteAll(),
      );
}
