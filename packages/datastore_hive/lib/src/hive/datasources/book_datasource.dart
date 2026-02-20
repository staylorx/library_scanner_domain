import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/book_model.dart';
import '../database/hive_database.dart';

class BookDatasource {
  final HiveDatabase _hiveDb;

  BookDatasource({required HiveDatabase hiveDb}) : _hiveDb = hiveDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _cast(dynamic raw) =>
      (raw as Map).cast<String, dynamic>();

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all books from the box.
  TaskEither<Failure, List<BookModel>> getAllBooks() => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      return box.values
          .map((v) => BookModel.fromMap(map: _cast(v)))
          .toList();
    },
    (error, _) => DatabaseFailure('Failed to get all books: $error'),
  );

  /// Returns a book by [id], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookById(String id) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.booksBox;
          final raw = box.get(id);
          return raw != null ? BookModel.fromMap(map: _cast(raw)) : null;
        },
        (error, _) => DatabaseFailure('Failed to get book by id: $error'),
      );

  /// Returns books that contain the given business ID [pair].
  TaskEither<Failure, List<BookModel>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      return box.values
          .where((v) {
            final map = _cast(v);
            final raw = map['businessIds'] as List<dynamic>? ?? [];
            return raw.any((e) {
              final idType = BookIdType.values.byName(e['idType'] as String);
              return BookIdPair(
                    idType: idType,
                    idCode: e['idCode'] as String,
                  ) ==
                  pair;
            });
          })
          .map((v) => BookModel.fromMap(map: _cast(v)))
          .toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get books by business id pair: $error'),
  );

  /// Returns books that list [authorId] among their authors.
  TaskEither<Failure, List<BookModel>> getBooksByAuthorId(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.booksBox;
          return box.values
              .where((v) {
                final map = _cast(v);
                final ids =
                    (map['authorIds'] as List<dynamic>?)?.cast<String>() ?? [];
                return ids.contains(authorId);
              })
              .map((v) => BookModel.fromMap(map: _cast(v)))
              .toList();
        },
        (error, _) =>
            DatabaseFailure('Failed to get books by author id: $error'),
      );

  /// Returns books that list [tagId] among their tags.
  TaskEither<Failure, List<BookModel>> getBooksByTagId(String tagId) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.booksBox;
          return box.values
              .where((v) {
                final map = _cast(v);
                final ids =
                    (map['tagIds'] as List<dynamic>?)?.cast<String>() ?? [];
                return ids.contains(tagId);
              })
              .map((v) => BookModel.fromMap(map: _cast(v)))
              .toList();
        },
        (error, _) =>
            DatabaseFailure('Failed to get books by tag id: $error'),
      );

  /// Returns the first book whose complete set of business IDs matches
  /// [businessIds], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      final target = BookIdPairs(pairs: businessIds);
      for (final v in box.values) {
        final map = _cast(v);
        final raw = map['businessIds'] as List<dynamic>? ?? [];
        final stored = raw.map((e) {
          final idType = BookIdType.values.byName(e['idType'] as String);
          return BookIdPair(idType: idType, idCode: e['idCode'] as String);
        }).toList();
        if (BookIdPairs(pairs: stored) == target) {
          return BookModel.fromMap(map: map);
        }
      }
      return null;
    },
    (error, _) =>
        DatabaseFailure('Failed to get book by business ids: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [book] in the box.
  TaskEither<Failure, Unit> saveBook(BookModel book) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      await box.put(book.id, book.toMap());
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save book: $error'),
  );

  /// Deletes the book with [id] from the box.
  TaskEither<Failure, Unit> deleteBook(String id) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      await box.delete(id);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete book: $error'),
  );

  /// Deletes all books from the box.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.booksBox;
      await box.clear();
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete all books: $error'),
  );

  /// Removes [authorId] from the `authorIds` list of every book that contains it.
  TaskEither<Failure, Unit> removeAuthorFromBooks(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.booksBox;
          final keys = box.keys.toList();
          for (final key in keys) {
            final raw = box.get(key);
            if (raw == null) continue;
            final model = BookModel.fromMap(map: _cast(raw));
            if (!model.authorIds.contains(authorId)) continue;
            final updated = model.copyWith(
              authorIds: model.authorIds.where((id) => id != authorId).toList(),
            );
            await box.put(key, updated.toMap());
          }
          return unit;
        },
        (error, _) =>
            DatabaseFailure('Failed to remove author from books: $error'),
      );
}
