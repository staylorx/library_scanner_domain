import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

class AuthorRepositoryImpl implements AbstractAuthorRepository {
  final AbstractDatabaseService _databaseService;

  AuthorRepositoryImpl({required AbstractDatabaseService databaseService})
    : _databaseService = databaseService;

  final logger = Logger('AuthorRepositoryImpl');

  @override
  Future<Either<Failure, List<Author>>> getAuthors() async {
    logger.info('Entering getAuthors');
    try {
      final result = await _databaseService.getAll(collection: 'authors');
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
        logger.info('Success in getAuthors, fetched ${authors.length} authors');
        logger.info('Output: ${authors.map((a) => a.name).toList()}');
        logger.info('Exiting getAuthors');
        return Either.right(authors);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Author?>> getAuthorByName({
    required String name,
  }) async {
    logger.info('Entering getAuthorByName with name: $name');
    try {
      final result = await _databaseService.query(
        collection: 'authors',
        filter: {'name': name},
      );
      return result.fold((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          logger.info('Author with name $name not found');
          logger.info('Output: null');
          logger.info('Exiting getAuthorByName');
          return Either.right(null);
        }
        try {
          final model = AuthorModel.fromMap(map: records.first);
          logger.info('Success, fetched author ${model.name}');
          final author = model.toEntity();
          logger.info('Output: ${author.name}');
          logger.info('Exiting getAuthorByName');
          return Either.right(author);
        } catch (e) {
          return Either.left(DataParsingFailure(e.toString()));
        }
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  }) async {
    logger.info('Entering getAuthorsByNames with names: $names');
    try {
      if (names.isEmpty) {
        logger.info('names is empty, returning empty list');
        logger.info('Output: []');
        logger.info('Exiting getAuthorsByNames');
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
        logger.info(
          'Success in getAuthorsByNames, fetched ${authors.length} authors',
        );
        logger.info('Output: ${authors.map((a) => a.name).toList()}');
        logger.info('Exiting getAuthorsByNames');
        return Either.right(authors);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addAuthor({required Author author}) async {
    logger.info('Entering addAuthor with author: ${author.name}');
    try {
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger.info('Transaction started for addAuthor');
          final model = AuthorModel.fromEntity(author);
          logger.info('Saving author ${author.name}');
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: author.key,
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
          logger.info('Author saved, updating relationships');
          final updateResult = await _updateRelationshipsForAuthor(
            author.name,
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
          logger.info('Transaction operation completed for addAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('Success added author ${author.name}');
        logger.info('Exiting addAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAuthor({required Author author}) async {
    logger.info('Entering updateAuthor with author: ${author.name}');
    try {
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger.info('Transaction started for updateAuthor');
          final existingEither = await getAuthorByName(name: author.name);
          if (existingEither.isLeft()) {
            throw Exception(
              existingEither.getLeft().getOrElse(
                () => DatabaseFailure('Failed to get existing author'),
              ),
            );
          }
          final existing = existingEither.getRight().getOrElse(() => null);
          if (existing != null) {
            logger.info(
              'Removing relationships for existing author ${existing.name}',
            );
            final removeResult = await _updateRelationshipsForAuthor(
              existing.name,
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
            // If key changed, delete the old record
            if (existing.key != author.key) {
              logger.info('Deleting old author record ${existing.key}');
              final deleteResult = await _databaseService.delete(
                collection: 'authors',
                id: existing.key,
                db: txn,
              );
              if (deleteResult.isLeft()) {
                throw Exception(
                  deleteResult.getLeft().getOrElse(
                    () => DatabaseFailure('Delete failed'),
                  ),
                );
              }
            }
          }
          final model = AuthorModel.fromEntity(author);
          logger.info('Saving updated author ${author.name}');
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: author.key,
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
          logger.info('Adding relationships for updated author ${author.name}');
          final addResult = await _updateRelationshipsForAuthor(
            author.name,
            isAdd: true,
          );
          if (addResult.isLeft()) {
            throw Exception(
              addResult.getLeft().getOrElse(
                () => DatabaseFailure('Add relationships failed'),
              ),
            );
          }
          logger.info('Transaction operation completed for updateAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('Success updated author ${author.name}');
        logger.info('Exiting updateAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAuthor({required Author author}) async {
    logger.info('Entering deleteAuthor with author: ${author.name}');
    try {
      final result = await _databaseService.transaction(
        operation: (dynamic txn) async {
          logger.info('Transaction started for deleteAuthor');
          final queryResult = await _databaseService.query(
            collection: 'authors',
            filter: {'name': author.name},
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
            logger.info('Deleting author record ${author.name}');
            // Assuming the first record's id is the key, but since we don't have keys, we need to delete by name
            // But delete takes id, and name is the key for authors
            final deleteResult = await _databaseService.delete(
              collection: 'authors',
              id: author.key,
              db: txn,
            );
            if (deleteResult.isLeft()) {
              throw Exception(
                deleteResult.getLeft().getOrElse(
                  () => DatabaseFailure('Delete failed'),
                ),
              );
            }
          }
          logger.info(
            'Updating relationships for deleted author ${author.name}',
          );
          final updateResult = await _updateRelationshipsForAuthor(
            author.name,
            isAdd: false,
          );
          if (updateResult.isLeft()) {
            throw Exception(
              updateResult.getLeft().getOrElse(
                () => DatabaseFailure('Update relationships failed'),
              ),
            );
          }
          logger.info('Transaction operation completed for deleteAuthor');
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('Success deleted author ${author.name}');
        logger.info('Exiting deleteAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _updateRelationshipsForAuthor(
    String authorName, {
    required bool isAdd,
    dynamic txn,
  }) async {
    logger.info(
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
      logger.info('Found ${bookMaps.length} books to check for relationships');
      for (final bookMap in bookMaps) {
        try {
          final bookModel = BookModel.fromMap(map: bookMap);
          if (bookModel.authorIds.contains(authorName)) {
            logger.info('Updating book ${bookModel.id} for author $authorName');
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
              idPairs: bookModel.idPairs,
              title: bookModel.title,
              description: bookModel.description,
              authorIds: updatedAuthorIds,
              tagIds: bookModel.tagIds,
              publishedDate: bookModel.publishedDate,
            );
            final saveResult = await _databaseService.save(
              collection: 'books',
              id: bookModel.id!,
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
            logger.info('Updated book ${bookModel.id}');
          }
        } catch (e) {
          return Either.left(DataParsingFailure(e.toString()));
        }
      }
      logger.info('Success in _updateRelationshipsForAuthor');
      logger.info('Exiting _updateRelationshipsForAuthor');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseConstraintFailure(e.toString()));
    }
  }
}
