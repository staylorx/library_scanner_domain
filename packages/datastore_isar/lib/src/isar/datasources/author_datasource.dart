import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/author_model.dart';
import '../../models/book_model.dart';
import '../database/isar_database.dart';
import '../schemas/author_schema.dart';
import '../schemas/book_schema.dart';

class AuthorDatasource {
  final IsarDatabase _isarDb;

  AuthorDatasource({required IsarDatabase isarDb}) : _isarDb = isarDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  AuthorModel _fromSchema(AuthorSchema schema) {
    final map = jsonDecode(schema.dataJson) as Map<String, dynamic>;
    return AuthorModel.fromMap(map: map);
  }

  AuthorSchema _toSchema(AuthorModel author) {
    return AuthorSchema()
      ..stringId = author.id
      ..name = author.name
      ..dataJson = jsonEncode(author.toMap());
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all authors from the collection.
  TaskEither<Failure, List<AuthorModel>> getAllAuthors() =>
      TaskEither.tryCatch(() async {
        final db = await _isarDb.isar;
        final schemas = await db.authorSchemas.where().findAll();
        return schemas.map(_fromSchema).toList();
      }, (error, _) => DatabaseFailure('Failed to get all authors: $error'));

  /// Returns an author matching [name], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorByName(String name) =>
      TaskEither.tryCatch(() async {
        final db = await _isarDb.isar;
        final schema = await db.authorSchemas
            .filter()
            .nameEqualTo(name)
            .findFirst();
        return schema != null ? _fromSchema(schema) : null;
      }, (error, _) => DatabaseFailure('Failed to get author by name: $error'));

  /// Returns authors whose names are in [names].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByNames(
    List<String> names,
  ) => TaskEither.tryCatch(() async {
    final db = await _isarDb.isar;
    final all = await db.authorSchemas.where().findAll();
    return all.where((s) => names.contains(s.name)).map(_fromSchema).toList();
  }, (error, _) => DatabaseFailure('Failed to get authors by names: $error'));

  /// Returns an author by [id], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorById(String id) =>
      TaskEither.tryCatch(() async {
        final db = await _isarDb.isar;
        final schema = await db.authorSchemas.getByStringId(id);
        return schema != null ? _fromSchema(schema) : null;
      }, (error, _) => DatabaseFailure('Failed to get author by id: $error'));

  /// Returns authors that match the given business ID [pair].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByBusinessIdPair(
    AuthorIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final all = await db.authorSchemas.where().findAll();
      return all
          .map(_fromSchema)
          .where(
            (model) => model.businessIds.any(
              (p) => p.idType == pair.idType && p.idCode == pair.idCode,
            ),
          )
          .toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get authors by business id pair: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [author] in the collection.
  TaskEither<Failure, Unit> saveAuthor(AuthorModel author) =>
      TaskEither.tryCatch(() async {
        final db = await _isarDb.isar;
        await db.authorSchemas.put(_toSchema(author));
        return unit;
      }, (error, _) => DatabaseFailure('Failed to save author: $error'));

  /// Deletes the author with [id] from the collection.
  TaskEither<Failure, Unit> deleteAuthor(String id) =>
      TaskEither.tryCatch(() async {
        final db = await _isarDb.isar;
        await db.authorSchemas.deleteByStringId(id);
        return unit;
      }, (error, _) => DatabaseFailure('Failed to delete author: $error'));

  /// Deletes all authors from the collection.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(() async {
    final db = await _isarDb.isar;
    await db.authorSchemas.clear();
    return unit;
  }, (error, _) => DatabaseFailure('Failed to delete all authors: $error'));

  /// Deletes [authorId] and all books that reference it.
  TaskEither<Failure, Unit> deleteAuthorWithCascade(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;

          final authorSchema = await db.authorSchemas.getByStringId(authorId);
          if (authorSchema == null) {
            throw const ServiceFailure('Author not found');
          }
          final author = _fromSchema(authorSchema);

          // Delete books that list this author.
          final allBooks = await db.bookSchemas.where().findAll();
          final bookIdsToDelete = allBooks
              .where((b) {
                final bookModel = BookModel.fromMap(
                  map: jsonDecode(b.dataJson) as Map<String, dynamic>,
                );
                return bookModel.authorIds.contains(author.id);
              })
              .map((b) => b.stringId)
              .toList();

          for (final bookId in bookIdsToDelete) {
            await db.bookSchemas.deleteByStringId(bookId);
          }
          await db.authorSchemas.deleteByStringId(author.id);
          return unit;
        },
        (error, _) => error is Failure
            ? error
            : DatabaseFailure('Failed to delete author with cascade: $error'),
      );
}
