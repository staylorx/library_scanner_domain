import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of author repository using Sembast.
class AuthorRepositoryImpl with Loggable implements AuthorRepository {
  final DatabaseService _databaseService;
  final AuthorIdRegistryService _idRegistryService;

  /// Creates an AuthorRepositoryImpl instance.
  AuthorRepositoryImpl({
    required DatabaseService databaseService,
    required AuthorIdRegistryService idRegistryService,
    Logger? logger,
  }) : _databaseService = databaseService,
       _idRegistryService = idRegistryService;

  /// Retrieves all authors from the database.
  @override
  Future<Either<Failure, List<Author>>> getAuthors() async {
    logger?.info('Entering getAuthors');
    return TaskEither.tryCatch(
      () async {
        final result = await _databaseService.getAll(collection: 'authors');
        return result.fold((failure) => throw failure, (records) {
          final authors = <Author>[];
          for (final record in records) {
            final model = AuthorModel.fromMap(map: record);
            authors.add(model.toEntity());
          }
          logger?.info(
            'Success in getAuthors, fetched ${authors.length} authors',
          );
          logger?.info('Output: ${authors.map((a) => a.name).toList()}');
          logger?.info('Exiting getAuthors');
          return authors;
        });
      },
      (error, stackTrace) =>
          error is Failure ? error : DatabaseReadFailure(error.toString()),
    ).run();
  }

  /// Retrieves an author by name.
  @override
  Future<Either<Failure, Author>> getByName({required String name}) async {
    logger?.info('Entering getByName with name: $name');
    try {
      final result = await _databaseService.query(
        collection: 'authors',
        filter: {'name': name},
      );
      return result.match(
        (failure) {
          logger?.warning('Failed to query author: $failure');
          return Either.left(failure);
        },
        (records) {
          if (records.isEmpty) {
            logger?.info('Author with name $name not found');
            logger?.info('Exiting getByName');
            return Either.left(NotFoundFailure('Author not found'));
          }
          try {
            final model = AuthorModel.fromMap(map: records.first);
            logger?.info('Success, fetched author ${model.name}');
            final author = model.toEntity();
            logger?.info('Output: ${author.name}');
            logger?.info('Exiting getByName');
            return Either.right(author);
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        },
      );
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Retrieves authors by a list of names.
  @override
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  }) async {
    logger?.info('Entering getAuthorsByNames with names: $names');
    try {
      if (names.isEmpty) {
        logger?.info('names is empty, returning empty list');
        logger?.info('Output: []');
        logger?.info('Exiting getAuthorsByNames');
        return Either.right([]);
      }

      final result = await _databaseService.query(
        collection: 'authors',
        filter: {
          'name': {'\$in': names},
        },
      );
      return result.fold((failure) => Either.left(failure), (records) {
        final authors = <Author>[];
        for (final record in records) {
          try {
            final model = AuthorModel.fromMap(map: record);
            authors.add(model.toEntity());
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        }
        logger?.info(
          'Success in getAuthorsByNames, fetched ${authors.length} authors',
        );
        logger?.info('Output: ${authors.map((a) => a.name).toList()}');
        logger?.info('Exiting getAuthorsByNames');
        return Either.right(authors);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Adds a new author to the database.
  @override
  Future<Either<Failure, AuthorHandle>> addAuthor({
    required Author author,
  }) async {
    logger?.info('Entering addAuthor with author: ${author.name}');
    try {
      final handle = AuthorHandle.fromName(author.name);
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger?.info('Transaction started for addAuthor');
          final model = AuthorModel.fromEntity(author, handle.toString());
          logger?.info('Saving author ${author.name} with handle $handle');
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: handle.toString(),
            data: model.toMap(),
            db: txn,
          );
          if (saveResult.isLeft()) {
            throw Exception(
              saveResult.getLeft().getOrElse(
                () => DatabaseFailure('Save failed'),
              ),
            );
          }
          logger?.info('Author saved, registering ID pairs');
          final registerResult = _idRegistryService.registerAuthorIdPairs(
            AuthorIdPairs(pairs: author.businessIds),
          );
          if (registerResult.isLeft()) {
            throw Exception(
              registerResult.getLeft().getOrElse(
                () => RegistryFailure('Register ID pairs failed'),
              ),
            );
          }
          logger?.info('ID pairs registered, updating relationships');
          final updateResult = await _updateRelationshipsForAuthor(
            authorName: author.name,
            isAdd: true,
            txn: txn,
          );
          if (updateResult.isLeft()) {
            throw Exception(
              updateResult.getLeft().getOrElse(
                () => DatabaseFailure('Update relationships failed'),
              ),
            );
          }
          logger?.info('Transaction operation completed for addAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger?.info('Success added author ${author.name} with handle $handle');
        logger?.info('Exiting addAuthor');
        return Either.right(handle);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Updates an existing author in the database.
  @override
  Future<Either<Failure, Unit>> updateAuthor({
    required AuthorHandle handle,
    required Author author,
  }) async {
    logger?.info(
      'Entering updateAuthor with handle: $handle and author: ${author.name}',
    );
    try {
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger?.info('Transaction started for updateAuthor');
          final newId = author.name;
          // Find existing author by handle
          final existingResult = await _databaseService.query(
            collection: 'authors',
            filter: {'id': handle.toString()},
            db: txn,
          );
          if (existingResult.isLeft()) {
            throw Exception(
              existingResult.getLeft().getOrElse(
                () => DatabaseFailure('Failed to query existing author'),
              ),
            );
          }
          final records = existingResult.getRight().getOrElse(() => []);
          Author? existing;
          if (records.isNotEmpty) {
            try {
              final model = AuthorModel.fromMap(map: records.first);
              existing = model.toEntity();
            } catch (e) {
              throw Exception(DataParsingFailure(e.toString()));
            }
          }
          if (existing != null) {
            logger?.info(
              'Unregistering old ID pairs for existing author ${existing.name}',
            );
            final unregisterResult = _idRegistryService.unregisterAuthorIdPairs(
              AuthorIdPairs(pairs: existing.businessIds),
            );
            if (unregisterResult.isLeft()) {
              throw Exception(
                unregisterResult.getLeft().getOrElse(
                  () => RegistryFailure('Unregister ID pairs failed'),
                ),
              );
            }
            logger?.info(
              'Removing relationships for existing author ${existing.name}',
            );
            final removeResult = await _updateRelationshipsForAuthor(
              authorName: existing.name,
              isAdd: false,
              txn: txn,
            );
            if (removeResult.isLeft()) {
              throw Exception(
                removeResult.getLeft().getOrElse(
                  () => DatabaseFailure('Remove relationships failed'),
                ),
              );
            }
          }
          if (handle.toString() != newId) {
            logger?.info('Name changed, deleting old record');
            final deleteResult = await _databaseService.delete(
              collection: 'authors',
              id: handle.toString(),
              db: txn,
            );
            if (deleteResult.isLeft()) {
              throw Exception(
                deleteResult.getLeft().getOrElse(
                  () => DatabaseFailure('Delete old record failed'),
                ),
              );
            }
          }
          final model = AuthorModel.fromEntity(author, handle.toString());
          logger?.info('Saving updated author ${author.name}');
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: newId,
            data: model.toMap(),
            db: txn,
          );
          if (saveResult.isLeft()) {
            throw Exception(
              saveResult.getLeft().getOrElse(
                () => DatabaseFailure('Save failed'),
              ),
            );
          }
          logger?.info(
            'Registering new ID pairs for updated author ${author.name}',
          );
          final registerResult = _idRegistryService.registerAuthorIdPairs(
            AuthorIdPairs(pairs: author.businessIds),
          );
          if (registerResult.isLeft()) {
            throw Exception(
              registerResult.getLeft().getOrElse(
                () => RegistryFailure('Register ID pairs failed'),
              ),
            );
          }
          logger?.info(
            'ID pairs registered, adding relationships for updated author ${author.name}',
          );
          final addResult = await _updateRelationshipsForAuthor(
            authorName: author.name,
            isAdd: true,
            txn: txn,
          );
          if (addResult.isLeft()) {
            throw Exception(
              addResult.getLeft().getOrElse(
                () => DatabaseFailure('Add relationships failed'),
              ),
            );
          }
          logger?.info('Transaction operation completed for updateAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger?.info('Success updated author ${author.name}');
        logger?.info('Exiting updateAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Deletes an author from the database.
  @override
  Future<Either<Failure, Unit>> deleteAuthor({
    required AuthorHandle handle,
  }) async {
    logger?.info('Entering deleteAuthor with handle: $handle');
    try {
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger?.info('Transaction started for deleteAuthor');
          final queryResult = await _databaseService.query(
            collection: 'authors',
            filter: {'id': handle.toString()},
            db: txn,
          );
          if (queryResult.isLeft()) {
            throw Exception(
              queryResult.getLeft().getOrElse(
                () => DatabaseFailure('Query failed'),
              ),
            );
          }
          final records = queryResult.getRight().getOrElse(() => []);
          if (records.isNotEmpty) {
            try {
              final model = AuthorModel.fromMap(map: records.first);
              final author = model.toEntity();
              logger?.info('Unregistering ID pairs for author ${author.name}');
              final unregisterResult = _idRegistryService
                  .unregisterAuthorIdPairs(
                    AuthorIdPairs(pairs: author.businessIds),
                  );
              if (unregisterResult.isLeft()) {
                throw Exception(
                  unregisterResult.getLeft().getOrElse(
                    () => RegistryFailure('Unregister ID pairs failed'),
                  ),
                );
              }
              logger?.info('Deleting author record $handle');
              final deleteResult = await _databaseService.delete(
                collection: 'authors',
                id: handle.toString(),
                db: txn,
              );
              if (deleteResult.isLeft()) {
                throw Exception(
                  deleteResult.getLeft().getOrElse(
                    () => DatabaseFailure('Delete failed'),
                  ),
                );
              }
              logger?.info(
                'Updating relationships for deleted author ${author.name}',
              );
              final updateResult = await _updateRelationshipsForAuthor(
                authorName: author.name,
                isAdd: false,
                txn: txn,
              );
              if (updateResult.isLeft()) {
                throw Exception(
                  updateResult.getLeft().getOrElse(
                    () => DatabaseFailure('Update relationships failed'),
                  ),
                );
              }
            } catch (e) {
              throw Exception(DataParsingFailure(e.toString()));
            }
          }
          logger?.info('Transaction operation completed for deleteAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger?.info('Success deleted author with handle $handle');
        logger?.info('Exiting deleteAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Retrieves an author by handle.
  @override
  Future<Either<Failure, Author>> getByHandle({
    required AuthorHandle handle,
  }) async {
    logger?.info('Entering getByHandle with handle: $handle');
    try {
      final result = await _databaseService.query(
        collection: 'authors',
        filter: {'id': handle.toString()},
      );
      return result.match(
        (failure) {
          logger?.warning(
            'Failed to get Author by handle: $handle, Error: ${failure.message}',
          );
          return Either.left(failure);
        },
        (records) {
          logger?.info('Successfully retrieved Author by handle: $handle');
          if (records.isEmpty) {
            logger?.info('Author with handle $handle not found');
            logger?.info('Exiting getByHandle');
            return Either.left(NotFoundFailure('Author not found'));
          }
          try {
            final model = AuthorModel.fromMap(map: records.first);
            logger?.info('Success, fetched author ${model.name}');
            final author = model.toEntity();
            logger?.info('Output: ${author.name}');
            logger?.info('Exiting getByHandle');
            return Either.right(author);
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        },
      );
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _updateRelationshipsForAuthor({
    required String authorName,
    required bool isAdd,
    dynamic txn,
  }) async {
    logger?.info(
      'Entering _updateRelationshipsForAuthor with authorName: $authorName, isAdd: $isAdd',
    );
    try {
      final booksResult = await _databaseService.getAll(
        collection: 'books',
        db: txn,
      );
      if (booksResult.isLeft()) {
        return Either.left(
          booksResult.getLeft().getOrElse(
            () => DatabaseFailure('Unexpected failure'),
          ),
        );
      }
      final bookMaps = booksResult.getRight().getOrElse(() => []);
      logger?.info('Found ${bookMaps.length} books to check for relationships');
      for (final bookMap in bookMaps) {
        try {
          final bookModel = BookModel.fromMap(map: bookMap);
          if (bookModel.authorIds.contains(authorName)) {
            logger?.info(
              'Updating book ${bookModel.id} for author $authorName',
            );
            final updatedAuthorIds = List<String>.from(bookModel.authorIds);
            if (isAdd) {
              if (!updatedAuthorIds.contains(authorName)) {
                updatedAuthorIds.add(authorName);
              }
            } else {
              updatedAuthorIds.remove(authorName);
            }
            final updatedBookModel = BookModel(
              id: bookModel.id,
              businessIds: bookModel.businessIds,
              title: bookModel.title,
              description: bookModel.description,
              authorIds: updatedAuthorIds,
              tagIds: bookModel.tagIds,
              publishedDate: bookModel.publishedDate,
            );
            final saveResult = await _databaseService.save(
              collection: 'books',
              id: bookModel.id,
              data: updatedBookModel.toMap(),
              db: txn,
            );
            if (saveResult.isLeft()) {
              return Either.left(
                saveResult.getLeft().getOrElse(
                  () => DatabaseFailure('Save failed'),
                ),
              );
            }
            logger?.info('Updated book ${bookModel.id}');
          }
        } catch (e) {
          return Either.left(DataParsingFailure(e.toString()));
        }
      }
      logger?.info('Success in _updateRelationshipsForAuthor');
      logger?.info('Exiting _updateRelationshipsForAuthor');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseConstraintFailure(e.toString()));
    }
  }
}
