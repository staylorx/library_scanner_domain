import 'package:datastore_sembast/src/models/book_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import 'sembast_database.dart';

class BookDatasource {
  final SembastDatabase _sembastDb;

  BookDatasource({required SembastDatabase sembastDb})
      : _sembastDb = sembastDb;

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all books from the store.
  TaskEither<Failure, List<BookModel>> getAllBooks() => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final records = await _sembastDb.booksStore.find(db);
      return records.map((r) => BookModel.fromMap(map: r.value)).toList();
    },
    (error, _) => DatabaseFailure('Failed to get all books: $error'),
  );

  /// Returns a book by [id], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookById(String id) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final record = await _sembastDb.booksStore.record(id).get(db);
          return record != null ? BookModel.fromMap(map: record) : null;
        },
        (error, _) => DatabaseFailure('Failed to get book by id: $error'),
      );

  /// Returns books that contain the given business ID [pair].
  TaskEither<Failure, List<BookModel>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          final raw = record['businessIds'] as List<dynamic>? ?? [];
          return raw.any((e) {
            final idType = BookIdType.values.byName(e['idType'] as String);
            return BookIdPair(idType: idType, idCode: e['idCode'] as String) ==
                pair;
          });
        }),
      );
      final records = await _sembastDb.booksStore.find(db, finder: finder);
      return records.map((r) => BookModel.fromMap(map: r.value)).toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get books by business id pair: $error'),
  );

  /// Returns books that list [authorId] among their authors.
  TaskEither<Failure, List<BookModel>> getBooksByAuthorId(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final finder = sembast.Finder(
            filter: sembast.Filter.custom((record) {
              final ids =
                  (record['authorIds'] as List<dynamic>?)?.cast<String>() ??
                  [];
              return ids.contains(authorId);
            }),
          );
          final records =
              await _sembastDb.booksStore.find(db, finder: finder);
          return records.map((r) => BookModel.fromMap(map: r.value)).toList();
        },
        (error, _) =>
            DatabaseFailure('Failed to get books by author id: $error'),
      );

  /// Returns books that list [tagId] among their tags.
  TaskEither<Failure, List<BookModel>> getBooksByTagId(String tagId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final finder = sembast.Finder(
            filter: sembast.Filter.custom((record) {
              final ids =
                  (record['tagIds'] as List<dynamic>?)?.cast<String>() ?? [];
              return ids.contains(tagId);
            }),
          );
          final records =
              await _sembastDb.booksStore.find(db, finder: finder);
          return records.map((r) => BookModel.fromMap(map: r.value)).toList();
        },
        (error, _) => DatabaseFailure('Failed to get books by tag id: $error'),
      );

  /// Returns the first book whose complete set of business IDs matches
  /// [businessIds], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final target = BookIdPairs(pairs: businessIds);
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          final raw = record['businessIds'] as List<dynamic>? ?? [];
          final stored = raw.map((e) {
            final idType = BookIdType.values.byName(e['idType'] as String);
            return BookIdPair(idType: idType, idCode: e['idCode'] as String);
          }).toList();
          return BookIdPairs(pairs: stored) == target;
        }),
      );
      final records = await _sembastDb.booksStore.find(db, finder: finder);
      return records.isEmpty ? null : BookModel.fromMap(map: records.first.value);
    },
    (error, _) =>
        DatabaseFailure('Failed to get book by business ids: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [book] in the store.
  TaskEither<Failure, Unit> saveBook(
    BookModel book, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.booksStore.record(book.id).put(db, book.toMap());
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save book: $error'),
  );

  /// Deletes the book with [id] from the store.
  TaskEither<Failure, Unit> deleteBook(
    String id, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.booksStore.record(id).delete(db);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete book: $error'),
  );

  /// Deletes all books from the store.
  TaskEither<Failure, Unit> deleteAll({sembast.DatabaseClient? txn}) =>
      TaskEither.tryCatch(
        () async {
          final db = txn ?? await _sembastDb.database;
          await _sembastDb.booksStore.delete(db);
          return unit;
        },
        (error, _) => DatabaseFailure('Failed to delete all books: $error'),
      );

  /// Removes [authorId] from the `authorIds` list of every book that contains it.
  TaskEither<Failure, Unit> removeAuthorFromBooks(
    String authorId, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      final records = await _sembastDb.booksStore.find(db);
      for (final record in records) {
        final model = BookModel.fromMap(map: record.value);
        if (!model.authorIds.contains(authorId)) continue;
        final updated = BookModel(
          id: model.id,
          businessIds: model.businessIds,
          title: model.title,
          description: model.description,
          authorIds: model.authorIds.where((id) => id != authorId).toList(),
          tagIds: model.tagIds,
          publishedDate: model.publishedDate,
        );
        await _sembastDb.booksStore
            .record(updated.id)
            .put(db, updated.toMap());
      }
      return unit;
    },
    (error, _) =>
        DatabaseFailure('Failed to remove author from books: $error'),
  );
}
