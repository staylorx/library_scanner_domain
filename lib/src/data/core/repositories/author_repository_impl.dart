import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

/// Implementation of author repository using Sembast.
class AuthorRepositoryImpl with Loggable implements AuthorRepository {
  final AuthorDatasource authorDatasource;
  final UnitOfWork unitOfWork;
  final AuthorIdRegistryService idRegistryService;

  /// Creates an AuthorRepositoryImpl instance.
  AuthorRepositoryImpl({
    required this.authorDatasource,
    required this.unitOfWork,
    required this.idRegistryService,
    Logger? logger,
  });

  /// Retrieves all authors from the database.
  @override
  TaskEither<Failure, List<Author>> getAuthors() {
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

  /// Adds a new author to the database.
  @override
  TaskEither<Failure, Author> addAuthor({
    required Author author,
    Transaction? txn,
  }) {
    logger?.info('Entering addAuthor with author: ${author.name}');
    final authorWithId = author.id.isNotEmpty
        ? author
        : author.copyWith(id: const Uuid().v4());
    final model = AuthorModel.fromEntity(authorWithId);
    final idPairs = AuthorIdPairs(pairs: authorWithId.businessIds);
    final registerResult = idRegistryService.registerAuthorIdPairs(idPairs);
    return registerResult.flatMap((_) {
      if (txn != null) {
        logger?.info('Using provided transaction for addAuthor');
        return authorDatasource
            .saveAuthor(model, txn: txn)
            .map((_) => authorWithId);
      } else {
        return unitOfWork.run((Transaction txn) {
          logger?.info('Transaction started for addAuthor');
          return authorDatasource.saveAuthor(model, txn: txn).map((_) {
            logger?.info('Transaction operation completed for addAuthor');
            return authorWithId;
          });
        });
      }
    });
  }

  /// Updates an existing author in the database.
  @override
  TaskEither<Failure, Unit> updateAuthor({
    required Author author,
    Transaction? txn,
  }) {
    logger?.info(
      'Entering updateAuthor with id: ${author.id} and author: ${author.name}',
    );
    return getAuthorById(id: author.id).flatMap((oldAuthor) {
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
          if (txn != null) {
            logger?.info('Using provided transaction for updateAuthor');
            return authorDatasource
                .saveAuthor(model, txn: txn)
                .map((_) => unit);
          } else {
            return unitOfWork.run((Transaction txn) {
              logger?.info('Transaction started for updateAuthor');
              return authorDatasource.saveAuthor(model, txn: txn).map((_) {
                logger?.info('Update author completed');
                return unit;
              });
            });
          }
        });
      });
    });
  }

  /// Deletes an author from the database.
  @override
  TaskEither<Failure, Unit> deleteAuthor({
    required Author author,
    Transaction? txn,
  }) {
    logger?.info('Entering deleteAuthor with id: ${author.id}');
    return getAuthorById(id: author.id).flatMap((author) {
      logger?.info('Author exists before deletion');
      final idPairs = AuthorIdPairs(pairs: author.businessIds);
      final unregisterResult = idRegistryService.unregisterAuthorIdPairs(
        idPairs,
      );
      return unregisterResult.flatMap((_) {
        if (txn != null) {
          logger?.info('Using provided transaction for deleteAuthor');
          return authorDatasource
              .deleteAuthorWithCascade(author.id, txn: txn)
              .map((_) => unit);
        } else {
          return unitOfWork.run((Transaction txn) {
            logger?.info('Transaction started for deleteAuthor');
            return authorDatasource
                .deleteAuthorWithCascade(author.id, txn: txn)
                .map((_) {
                  logger?.info('Delete author completed successfully');
                  return unit;
                });
          });
        }
      });
    });
  }

  /// Retrieves an author by id.
  @override
  TaskEither<Failure, Author> getAuthorById({required String id}) {
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
}
