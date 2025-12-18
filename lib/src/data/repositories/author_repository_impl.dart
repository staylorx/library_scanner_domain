import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

class AuthorRepositoryImpl implements IAuthorRepository {
  final AbstractDatabaseService _databaseService;

  AuthorRepositoryImpl({required AbstractDatabaseService databaseService})
    : _databaseService = databaseService;

  final logger = Logger('AuthorRepositoryImpl');

  @override
  Future<Either<Failure, List<Author>>> getAuthors() async {
    logger.info('AuthorRepositoryImpl: Entering getAuthors');
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
        logger.info(
          'AuthorRepositoryImpl: Success in getAuthors, fetched ${authors.length} authors',
        );
        logger.info(
          'AuthorRepositoryImpl: Output: ${authors.map((a) => a.name).toList()}',
        );
        logger.info('AuthorRepositoryImpl: Exiting getAuthors');
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
    logger.info(
      'AuthorRepositoryImpl: Entering getAuthorByName with name: $name',
    );
    try {
      final result = await _databaseService.query(
        collection: 'authors',
        filter: {'name': name},
      );
      return result.fold((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          logger.info('AuthorRepositoryImpl: Author with name $name not found');
          logger.info('AuthorRepositoryImpl: Output: null');
          logger.info('AuthorRepositoryImpl: Exiting getAuthorByName');
          return Either.right(null);
        }
        try {
          final model = AuthorModel.fromMap(map: records.first);
          logger.info(
            'AuthorRepositoryImpl: Success, fetched author ${model.name}',
          );
          final author = model.toEntity();
          logger.info('AuthorRepositoryImpl: Output: ${author.name}');
          logger.info('AuthorRepositoryImpl: Exiting getAuthorByName');
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
    logger.info(
      'AuthorRepositoryImpl: Entering getAuthorsByNames with names: $names',
    );
    try {
      if (names.isEmpty) {
        logger.info(
          'AuthorRepositoryImpl: names is empty, returning empty list',
        );
        logger.info('AuthorRepositoryImpl: Output: []');
        logger.info('AuthorRepositoryImpl: Exiting getAuthorsByNames');
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
          'AuthorRepositoryImpl: Success in getAuthorsByNames, fetched ${authors.length} authors',
        );
        logger.info(
          'AuthorRepositoryImpl: Output: ${authors.map((a) => a.name).toList()}',
        );
        logger.info('AuthorRepositoryImpl: Exiting getAuthorsByNames');
        return Either.right(authors);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addAuthor({required Author author}) async {
    logger.info(
      'AuthorRepositoryImpl: Entering addAuthor with author: ${author.name}',
    );
    try {
      final result = await _databaseService.transaction(
        operation: () async {
          final model = AuthorModel.fromEntity(author);
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: author.key,
            data: model.toMap(),
          );
          if (saveResult.isLeft()) {
            throw Exception(
              saveResult.getLeft().getOrElse(
                () => DatabaseFailure('Save failed'),
              ),
            );
          }
          final updateResult = await _updateRelationshipsForAuthor(
            author.name,
            isAdd: true,
          );
          if (updateResult.isLeft()) {
            throw Exception(
              updateResult.getLeft().getOrElse(
                () => DatabaseFailure('Update relationships failed'),
              ),
            );
          }
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info(
          'AuthorRepositoryImpl: Success added author ${author.name}',
        );
        logger.info('AuthorRepositoryImpl: Exiting addAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAuthor({required Author author}) async {
    logger.info(
      'AuthorRepositoryImpl: Entering updateAuthor with author: ${author.name}',
    );
    try {
      final result = await _databaseService.transaction(
        operation: () async {
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
            final removeResult = await _updateRelationshipsForAuthor(
              existing.name,
              isAdd: false,
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
              final deleteResult = await _databaseService.delete(
                collection: 'authors',
                id: existing.key,
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
          final saveResult = await _databaseService.save(
            collection: 'authors',
            id: author.key,
            data: model.toMap(),
          );
          if (saveResult.isLeft()) {
            throw Exception(
              saveResult.getLeft().getOrElse(
                () => DatabaseFailure('Save failed'),
              ),
            );
          }
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
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info(
          'AuthorRepositoryImpl: Success updated author ${author.name}',
        );
        logger.info('AuthorRepositoryImpl: Exiting updateAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAuthor({required Author author}) async {
    logger.info(
      'AuthorRepositoryImpl: Entering deleteAuthor with author: ${author.name}',
    );
    try {
      final result = await _databaseService.transaction(
        operation: () async {
          final queryResult = await _databaseService.query(
            collection: 'authors',
            filter: {'name': author.name},
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
            // Assuming the first record's id is the key, but since we don't have keys, we need to delete by name
            // But delete takes id, and name is the key for authors
            final deleteResult = await _databaseService.delete(
              collection: 'authors',
              id: author.name,
            );
            if (deleteResult.isLeft()) {
              throw Exception(
                deleteResult.getLeft().getOrElse(
                  () => DatabaseFailure('Delete failed'),
                ),
              );
            }
          }
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
        },
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info(
          'AuthorRepositoryImpl: Success deleted author ${author.name}',
        );
        logger.info('AuthorRepositoryImpl: Exiting deleteAuthor');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _updateRelationshipsForAuthor(
    String authorName, {
    required bool isAdd,
  }) async {
    logger.info(
      'AuthorRepositoryImpl: Entering _updateRelationshipsForAuthor with authorName: $authorName, isAdd: $isAdd',
    );
    try {
      final booksResult = await _databaseService.getAll(collection: 'books');
      return booksResult.fold((failure) => Either.left(failure), (
        bookMaps,
      ) async {
        for (final bookMap in bookMaps) {
          try {
            final bookModel = BookModel.fromMap(map: bookMap);
            if (bookModel.authorIds.contains(authorName)) {
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
              );
              if (saveResult.isLeft()) {
                return Either.left(
                  saveResult.getLeft().getOrElse(
                    () => DatabaseFailure('Save failed'),
                  ),
                );
              }
            }
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        }
        logger.info(
          'AuthorRepositoryImpl: Success in _updateRelationshipsForAuthor',
        );
        logger.info(
          'AuthorRepositoryImpl: Exiting _updateRelationshipsForAuthor',
        );
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseConstraintFailure(e.toString()));
    }
  }
}
