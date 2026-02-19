import 'package:datastore_sembast/src/models/book_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import 'sembast_database.dart';


class BookDatasource {
  final SembastDatabase _sembastDb;

  /// Creates a datasource with required SembastDatabase.
  BookDatasource({required SembastDatabase sembastDb}) : _sembastDb = sembastDb;

  /// Retrieves all books from the store.
  TaskEither<Failure, List<BookModel>> getAllBooks() {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final records = await _sembastDb.booksStore.find(db);
      return records.map((r) => BookModel.fromMap(map: r.value)).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get all books: $error'));
  }

  /// Retrieves a book by ID.
  TaskEither<Failure, BookModel?> getBookById(String id) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final record = await _sembastDb.booksStore.record(id).get(db);
      return record != null ? BookModel.fromMap(map: record) : null;
    }, (error, stackTrace) => DatabaseFailure('Failed to get book by id: $error'));
  }

  /// Retrieves books containing a specific business ID pair.
  TaskEither<Failure, List<BookModel>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          final businessIdsRaw =
              record['businessIds'] as List<dynamic>? ?? [];
          final businessIds = businessIdsRaw.map((e) {
            final idTypeString = e['idType'] as String;
            final idType = BookIdType.values.byName(idTypeString);
            return BookIdPair(
              idType: idType,
              idCode: e['idCode'] as String,
            );
          }).toList();
          return businessIds.any((p) => p == pair);
        }),
      );
      final records = await _sembastDb.booksStore.find(db, finder: finder);
      return records.map((r) => BookModel.fromMap(map: r.value)).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get books by business id pair: $error'));
  }

  /// Retrieves books by author ID.
  TaskEither<Failure, List<BookModel>> getBooksByAuthorId(
    String authorId,
  ) => TaskEither.tryCatch(() async {
    final db = await _sembastDb.database;
    final finder = sembast.Finder(
      filter: sembast.Filter.custom((record) {
        final authorIds = (record['authorIds'] as List<dynamic>?)?.cast<String>() ?? [];
        return authorIds.contains(authorId);
      }),
    );
    final records = await _sembastDb.booksStore.find(db, finder: finder);
    return records.map((r) => BookModel.fromMap(map: r.value)).toList();
  }, (error, stackTrace) => DatabaseFailure('Failed to get books by author id: $error'));

  /// Retrieves books by tag ID.
  TaskEither<Failure, List<BookModel>> getBooksByTagId(String tagId) =>
      TaskEither.tryCatch(() async {
    final db = await _sembastDb.database;
    final finder = sembast.Finder(
      filter: sembast.Filter.custom((record) {
        final tagIds = (record['tagIds'] as List<dynamic>?)?.cast<String>() ?? [];
        return tagIds.contains(tagId);
      }),
    );
    final records = await _sembastDb.booksStore.find(db, finder: finder);
    return records.map((r) => BookModel.fromMap(map: r.value)).toList();
  }, (error, stackTrace) => DatabaseFailure('Failed to get books by tag id: $error'));

  /// Retrieves a book by exact business IDs.
  TaskEither<Failure, BookModel?> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) => TaskEither.tryCatch(() async {
    final db = await _sembastDb.database;
    final finder = sembast.Finder(
      filter: sembast.Filter.custom((record) {
        final businessIdsRaw = record['businessIds'] as List<dynamic>? ?? [];
        final recordBusinessIds = businessIdsRaw.map((e) {
          final idTypeString = e['idType'] as String;
          final idType = BookIdType.values.byName(idTypeString);
          return BookIdPair(idType: idType, idCode: e['idCode'] as String);
        }).toList();
        return BookIdPairs(pairs: recordBusinessIds) == BookIdPairs(pairs: businessIds);
      }),
    );
    final records = await _sembastDb.booksStore.find(db, finder: finder);
    if (records.isEmpty) {
      return null;
    }
    return BookModel.fromMap(map: records.first.value);
  }, (error, stackTrace) => DatabaseFailure('Failed to get book by business ids: $error'));

  /// Saves a book to the store.
  TaskEither<Failure, Unit> saveBook(BookModel book, {sembast.DatabaseClient? txn}) {
    return TaskEither.tryCatch(() async {
      final data = book.toMap();
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.booksStore.record(book.id).put(db, data);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to save book: $error'));
  }

  /// Deletes a book by ID.
  TaskEither<Failure, Unit> deleteBook(String id, {sembast.DatabaseClient? txn}) {
    return TaskEither.tryCatch(() async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.booksStore.record(id).delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to delete book: $error'));
  }

  /// Removes author from books.
  TaskEither<Failure, Unit> removeAuthorFromBooks(
    String name, {
    sembast.DatabaseClient? txn,
  }) {
    return TaskEither.tryCatch(() async {
      final db = txn ?? await _sembastDb.database;
      final records = await _sembastDb.booksStore.find(db);
      for (final record in records) {
        final model = BookModel.fromMap(map: record.value);
        if (model.authorIds.contains(name)) {
          final updatedAuthorIds = List<String>.from(model.authorIds)..remove(name);
          final updatedModel = BookModel(
            id: model.id,
            businessIds: model.businessIds,
            title: model.title,
            description: model.description,
            authorIds: updatedAuthorIds,
            tagIds: model.tagIds,
            publishedDate: model.publishedDate,
          );
          await _sembastDb.booksStore.record(updatedModel.id).put(db, updatedModel.toMap());
        }
      }
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to remove author from books: $error'));
  }

  /// Executes a transaction with the given operation.
  TaskEither<Failure, Unit> transaction(
    Future<Unit> Function(sembast.DatabaseClient txn) operation,
  ) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      await db.transaction((txn) async {
        await operation(txn);
      });
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Transaction failed: $error'));
  }
}
