import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/core/models/book_model.dart';

class BookDatasource {
  final DatabaseService _dbService;

  /// Creates a datasource with required DatabaseService.
  BookDatasource({required DatabaseService dbService}) : _dbService = dbService;

  /// Retrieves all books from the store.
  Future<Either<Failure, List<BookModel>>> getAllBooks() async {
    try {
      final result = await _dbService.getAll(collection: 'books');
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => BookModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get all books: $e'));
    }
  }

  /// Retrieves a book by ID.
  Future<Either<Failure, BookModel?>> getBookById(String id) async {
    try {
      final result = await _dbService.query(
        collection: 'books',
        filter: {'id': id},
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(BookModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get book by ID: $e'));
    }
  }

  /// Retrieves books containing a specific business ID pair.
  Future<Either<Failure, List<BookModel>>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) async {
    try {
      final result = await _dbService.query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final businessIdsRaw =
                record.value['businessIds'] as List<dynamic>? ?? [];
            final businessIds = businessIdsRaw.map((e) {
              final idTypeString = e['idType'] as String;
              final idType = BookIdType.values.byName(idTypeString);
              return BookIdPair(idType: idType, idCode: e['idCode'] as String);
            }).toList();
            return businessIds.any((p) => p == pair);
          },
        },
      );
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => BookModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(
        ServiceFailure('Failed to get books by business ID pair: $e'),
      );
    }
  }

  /// Retrieves books by author ID.
  Future<Either<Failure, List<BookModel>>> getBooksByAuthorId(
    String authorId,
  ) async {
    try {
      final result = await _dbService.query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final authorIds = record.value['authorIds'] as List<String>? ?? [];
            return authorIds.contains(authorId);
          },
        },
      );
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => BookModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(
        ServiceFailure('Failed to get books by author ID: $e'),
      );
    }
  }

  /// Retrieves books by tag ID.
  Future<Either<Failure, List<BookModel>>> getBooksByTagId(String tagId) async {
    try {
      final result = await _dbService.query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final tagIds = record.value['tagIds'] as List<String>? ?? [];
            return tagIds.contains(tagId);
          },
        },
      );
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => BookModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get books by tag ID: $e'));
    }
  }

  /// Retrieves a book by exact business IDs.
  Future<Either<Failure, BookModel?>> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) async {
    try {
      final result = await _dbService.query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final businessIdsRaw =
                record.value['businessIds'] as List<dynamic>? ?? [];
            final recordBusinessIds = businessIdsRaw.map((e) {
              final idTypeString = e['idType'] as String;
              final idType = BookIdType.values.byName(idTypeString);
              return BookIdPair(idType: idType, idCode: e['idCode'] as String);
            }).toList();
            return BookIdPairs(pairs: recordBusinessIds) ==
                BookIdPairs(pairs: businessIds);
          },
        },
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(BookModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(
        ServiceFailure('Failed to get book by business IDs: $e'),
      );
    }
  }

  /// Saves a book to the store.
  Future<Either<Failure, Unit>> saveBook(BookModel book, {dynamic db}) async {
    try {
      final data = book.toMap();
      final result = await _dbService.save(
        collection: 'books',
        id: book.id,
        data: data,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to save book: $e'));
    }
  }

  /// Deletes a book by ID.
  Future<Either<Failure, Unit>> deleteBook(String id, {dynamic db}) async {
    try {
      final result = await _dbService.delete(
        collection: 'books',
        id: id,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to delete book: $e'));
    }
  }

  /// Removes author from books.
  Future<Either<Failure, Unit>> removeAuthorFromBooks(
    String name, {
    dynamic db,
  }) async {
    try {
      final result = await _dbService.getAll(collection: 'books', db: db);
      return result.match((failure) => Either.left(failure), (records) async {
        for (final record in records) {
          final model = BookModel.fromMap(map: record);
          if (model.authorIds.contains(name)) {
            final updatedAuthorIds = List<String>.from(model.authorIds)
              ..remove(name);
            final updatedModel = BookModel(
              id: model.id,
              businessIds: model.businessIds,
              title: model.title,
              description: model.description,
              authorIds: updatedAuthorIds,
              tagIds: model.tagIds,
              publishedDate: model.publishedDate,
            );
            final saveResult = await saveBook(updatedModel, db: db);
            if (saveResult.isLeft()) {
              return saveResult;
            }
          }
        }
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(
        ServiceFailure('Failed to remove author from books: $e'),
      );
    }
  }

  /// Executes a transaction with the given operation.
  Future<Either<Failure, Unit>> transaction(
    Future<void> Function(dynamic txn) operation,
  ) async {
    final result = await _dbService.transaction(operation: operation);
    return result.map((_) => unit);
  }
}
