import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/book_model.dart';
import '../database/isar_database.dart';
import '../schemas/book_schema.dart';

class BookDatasource {
  final IsarDatabase _isarDb;

  BookDatasource({required IsarDatabase isarDb}) : _isarDb = isarDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  BookModel _fromSchema(BookSchema schema) {
    final map = jsonDecode(schema.dataJson) as Map<String, dynamic>;
    return BookModel.fromMap(map: map);
  }

  BookSchema _toSchema(BookModel book) {
    return BookSchema()
      ..stringId = book.id
      ..title = book.title
      ..authorIds = book.authorIds
      ..tagIds = book.tagIds
      ..dataJson = jsonEncode(book.toMap());
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all books from the collection.
  TaskEither<Failure, List<BookModel>> getAllBooks() => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final schemas = await db.bookSchemas.where().findAll();
      return schemas.map(_fromSchema).toList();
    },
    (error, _) => DatabaseFailure('Failed to get all books: $error'),
  );

  /// Returns a book by [id], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookById(String id) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final schema = await db.bookSchemas.getByStringId(id);
          return schema != null ? _fromSchema(schema) : null;
        },
        (error, _) => DatabaseFailure('Failed to get book by id: $error'),
      );

  /// Returns books that contain the given business ID [pair].
  TaskEither<Failure, List<BookModel>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final all = await db.bookSchemas.where().findAll();
      return all
          .map(_fromSchema)
          .where((model) => model.businessIds.any(
            (p) => p.idType == pair.idType && p.idCode == pair.idCode,
          ))
          .toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get books by business id pair: $error'),
  );

  /// Returns books that list [authorId] among their authors.
  TaskEither<Failure, List<BookModel>> getBooksByAuthorId(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final schemas = await db.bookSchemas
              .filter()
              .authorIdsElementEqualTo(authorId)
              .findAll();
          return schemas.map(_fromSchema).toList();
        },
        (error, _) =>
            DatabaseFailure('Failed to get books by author id: $error'),
      );

  /// Returns books that list [tagId] among their tags.
  TaskEither<Failure, List<BookModel>> getBooksByTagId(String tagId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final schemas = await db.bookSchemas
              .filter()
              .tagIdsElementEqualTo(tagId)
              .findAll();
          return schemas.map(_fromSchema).toList();
        },
        (error, _) => DatabaseFailure('Failed to get books by tag id: $error'),
      );

  /// Returns the first book whose complete set of business IDs matches
  /// [businessIds], or `null` if not found.
  TaskEither<Failure, BookModel?> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final target = BookIdPairs(pairs: businessIds);
      final all = await db.bookSchemas.where().findAll();
      for (final schema in all) {
        final model = _fromSchema(schema);
        if (BookIdPairs(pairs: model.businessIds) == target) {
          return model;
        }
      }
      return null;
    },
    (error, _) =>
        DatabaseFailure('Failed to get book by business ids: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [book] in the collection.
  TaskEither<Failure, Unit> saveBook(BookModel book) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.bookSchemas.put(_toSchema(book));
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save book: $error'),
  );

  /// Deletes the book with [id] from the collection.
  TaskEither<Failure, Unit> deleteBook(String id) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.bookSchemas.deleteByStringId(id);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete book: $error'),
  );

  /// Deletes all books from the collection.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.bookSchemas.clear();
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete all books: $error'),
  );

  /// Removes [authorId] from the `authorIds` list of every book that contains it.
  TaskEither<Failure, Unit> removeAuthorFromBooks(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final schemas = await db.bookSchemas
              .filter()
              .authorIdsElementEqualTo(authorId)
              .findAll();
          for (final schema in schemas) {
            final model = _fromSchema(schema);
            final updated = model.copyWith(
              authorIds:
                  model.authorIds.where((id) => id != authorId).toList(),
            );
            await db.bookSchemas.put(_toSchema(updated));
          }
          return unit;
        },
        (error, _) =>
            DatabaseFailure('Failed to remove author from books: $error'),
      );
}
