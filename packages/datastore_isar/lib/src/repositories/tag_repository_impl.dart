import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';

import '../isar/datasources/tag_datasource.dart';
import '../models/tag_model.dart';
import 'base_repository.dart';

/// Isar implementation of [TagRepository].
class TagRepositoryImpl extends IsarBaseRepository
    with Loggable
    implements TagRepository {
  final TagDatasource _tagDatasource;

  TagRepositoryImpl({
    required TagDatasource tagDatasource,
    required UnitOfWork<TransactionHandle> unitOfWork,
    Logger? logger,
  }) : _tagDatasource = tagDatasource,
       super(unitOfWork) {
    this.logger = logger;
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  @override
  TaskEither<Failure, List<Tag>> getAll() =>
      _tagDatasource.getAllTags().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );

  @override
  TaskEither<Failure, Tag> getById({required String id}) =>
      _tagDatasource.getTagById(id).flatMap(
        (model) => model != null
            ? TaskEither.right(model.toEntity())
            : TaskEither.left(NotFoundFailure('Tag not found')),
      );

  @override
  TaskEither<Failure, Tag> getByName({required String name}) =>
      _tagDatasource.getTagByName(name).flatMap(
        (model) => model != null
            ? TaskEither.right(model.toEntity())
            : TaskEither.left(NotFoundFailure('Tag not found')),
      );

  @override
  TaskEither<Failure, List<Tag>> getTagsByNames({
    required List<String> names,
  }) {
    if (names.isEmpty) return TaskEither.right([]);
    return _tagDatasource
        .getTagsByNames(names)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  // ─── Write operations ─────────────────────────────────────────────────────

  @override
  TaskEither<Failure, Tag> create({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final tag =
        item.id.isNotEmpty ? item : item.copyWith(id: const Uuid().v4());
    final model = TagModel.fromEntity(tag);
    return runInTransaction(
      txn: txn,
      operation: (_) => _tagDatasource.saveTag(model).map((_) => tag),
    );
  }

  @override
  TaskEither<Failure, Tag> update({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    return runInTransaction(
      txn: txn,
      operation: (_) =>
          _tagDatasource.getTagById(item.id).flatMap((existing) {
            final existingBookIds = existing?.bookIds ?? [];
            final model = TagModel.fromEntity(
              item,
              existingBookIds: existingBookIds,
            );
            return _tagDatasource.saveTag(model).map((_) => item);
          }),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteById({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) => runInTransaction(
    txn: txn,
    operation: (_) => _tagDatasource.deleteTag(item.id).map((_) => unit),
  );

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) =>
      runInTransaction(
        txn: txn,
        operation: (_) => _tagDatasource.deleteAll(),
      );
}
