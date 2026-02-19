import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';
import '../sembast/datasources/author_datasource.dart';
import '../models/author_model.dart';
import 'base_repository.dart';

/// Implementation of author repository using Sembast.
class AuthorRepositoryImpl extends SembastBaseRepository
    with Loggable
    implements AuthorRepository {
  final AuthorDatasource authorDatasource;
  final AuthorIdRegistryService idRegistryService;

  /// Creates an AuthorRepositoryImpl instance.
  AuthorRepositoryImpl({
    required this.authorDatasource,
    required UnitOfWork<TransactionHandle> unitOfWork,
    required this.idRegistryService,
    Logger? logger,
  }) : super(unitOfWork) {
    this.logger = logger;
  }

  /// Retrieves all authors from the database.
  @override
  TaskEither<Failure, List<Author>> getAll() {
    return authorDatasource.getAllAuthors().map((models) {
      final authors = <Author>[];
      for (final model in models) {
        final author = model.toEntity();
        authors.add(author);
      }
      return authors;
    });
  }

  /// Retrieves an author by name.
  @override
  TaskEither<Failure, Author> getAuthorByName({required String name}) {
    return authorDatasource.getAuthorByName(name).flatMap((model) {
      if (model == null) {
        return TaskEither.left(NotFoundFailure('Author not found'));
      }
      return TaskEither.right(model.toEntity());
    });
  }

  /// Retrieves authors by a list of names.
  @override
  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  }) {
    logger?.info('Entering getAuthorsByNames with names: $names');
    if (names.isEmpty) {
      logger?.info('names is empty, returning empty list');
      return TaskEither.right([]);
    }
    return authorDatasource.getAuthorsByNames(names).map((models) {
      final authors = <Author>[];
      for (final model in models) {
        final author = model.toEntity();
        authors.add(author);
      }
      logger?.info(
        'Success in getAuthorsByNames, fetched ${authors.length} authors',
      );
      return authors;
    });
  }

  /// Creates a new author in the database.
  @override
  TaskEither<Failure, Author> create({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final author = item;
    logger?.info('Entering createAuthor with author: ${author.name}');
    final authorWithId = author.id.isNotEmpty
        ? author
        : author.copyWith(id: const Uuid().v4());
    final model = AuthorModel.fromEntity(authorWithId);
    final idPairs = AuthorIdPairs(pairs: authorWithId.businessIds);
    final registerResult = idRegistryService.registerAuthorIdPairs(idPairs);
    return registerResult.flatMap((_) {
      logger?.info('Transaction started for createAuthor');
      return runInTransaction(
        txn: txn,
        operation: (dbClient) =>
            authorDatasource.saveAuthor(model, txn: dbClient).map((_) {
              logger?.info('Transaction operation completed for createAuthor');
              return authorWithId;
            }),
      );
    });
  }

  /// Updates an existing author in the database.
  /// Updates an existing author in the database.
  @override
  TaskEither<Failure, Author> update({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final author = item;
    logger?.info(
      'Entering updateAuthor with id: ${author.id} and author: ${author.name}',
    );
    return getById(id: author.id).flatMap((oldAuthor) {
      final oldIdPairs = AuthorIdPairs(pairs: oldAuthor.businessIds);
      final newIdPairs = AuthorIdPairs(pairs: author.businessIds);
      final unregisterResult = idRegistryService.unregisterAuthorIdPairs(
        oldIdPairs,
      );
      return unregisterResult.flatMap((_) {
        final registerResult = idRegistryService.registerAuthorIdPairs(
          newIdPairs,
        );
        return registerResult.flatMap((_) {
          final model = AuthorModel.fromEntity(author);
          logger?.info('Transaction started for updateAuthor');
          return runInTransaction(
            txn: txn,
            operation: (dbClient) =>
                authorDatasource.saveAuthor(model, txn: dbClient).map((_) {
                  logger?.info('Update author completed');
                  return author;
                }),
          );
        });
      });
    });
  }

  /// Deletes an author from the database.
  /// Deletes an author from the database.
  @override
  TaskEither<Failure, Unit> deleteById({
    required Author item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final author = item;
    logger?.info('Entering deleteAuthor with id: ${author.id}');
    return getById(id: author.id).flatMap((author) {
      logger?.info('Author exists before deletion');
      final idPairs = AuthorIdPairs(pairs: author.businessIds);
      final unregisterResult = idRegistryService.unregisterAuthorIdPairs(
        idPairs,
      );
      return unregisterResult.flatMap((_) {
        logger?.info('Transaction started for deleteAuthor');
        return runInTransaction(
          txn: txn,
          operation: (dbClient) => authorDatasource
              .deleteAuthorWithCascade(author.id, txn: dbClient)
              .map((_) {
                logger?.info('Delete author completed successfully');
                return unit;
              }),
        );
      });
    });
  }

  /// Retrieves an author by id.
  @override
  TaskEither<Failure, Author> getById({required String id}) {
    logger?.info('Entering getById with id: $id');
    return authorDatasource.getAuthorById(id).flatMap((model) {
      logger?.info('Successfully retrieved Author by id: $id');
      if (model == null) {
        logger?.info('Author with id $id not found');
        return TaskEither.left(NotFoundFailure('Author not found'));
      }
      final author = model.toEntity();
      logger?.info('Output: ${author.name}');
      return TaskEither.right(author);
    });
  }

  /// Retrieves an author by its ID pair.
  @override
  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  }) {
    logger?.info('Entering getByIdPair with authorIdPair: $authorIdPair');
    return authorDatasource.getAuthorsByBusinessIdPair(authorIdPair).flatMap((
      models,
    ) {
      if (models.isEmpty) {
        logger?.debug('Author not found');
        return TaskEither.left(NotFoundFailure('Author not found'));
      }
      final author = models.first.toEntity();
      logger?.debug('Output: ${author.name}');
      return TaskEither.right(author);
    });
  }

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) {
    throw UnimplementedError();
  }

  TaskEither<Failure, Author> updateAuthor({
    required Author author,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    return update(item: author, txn: txn);
  }
}
