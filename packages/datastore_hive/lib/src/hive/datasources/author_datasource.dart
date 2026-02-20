import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/author_model.dart';
import '../../models/book_model.dart';
import '../database/hive_database.dart';

class AuthorDatasource {
  final HiveDatabase _hiveDb;

  AuthorDatasource({required HiveDatabase hiveDb}) : _hiveDb = hiveDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Casts a raw Hive value to `Map<String, dynamic>`.
  ///
  /// Hive stores values as `Map<dynamic, dynamic>`; all keys are strings in
  /// practice, so this cast is safe.
  Map<String, dynamic> _cast(dynamic raw) =>
      (raw as Map).cast<String, dynamic>();

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all authors from the box.
  TaskEither<Failure, List<AuthorModel>> getAllAuthors() =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.authorsBox;
          return box.values
              .map((v) => AuthorModel.fromMap(map: _cast(v)))
              .toList();
        },
        (error, _) => DatabaseFailure('Failed to get all authors: $error'),
      );

  /// Returns an author matching [name], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorByName(String name) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.authorsBox;
          final match = box.values.cast<dynamic>().firstWhere(
            (v) => (_cast(v)['name'] as String?) == name,
            orElse: () => null,
          );
          return match != null ? AuthorModel.fromMap(map: _cast(match)) : null;
        },
        (error, _) => DatabaseFailure('Failed to get author by name: $error'),
      );

  /// Returns authors whose names are in [names].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByNames(
    List<String> names,
  ) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.authorsBox;
      return box.values
          .where((v) => names.contains((_cast(v))['name'] as String?))
          .map((v) => AuthorModel.fromMap(map: _cast(v)))
          .toList();
    },
    (error, _) => DatabaseFailure('Failed to get authors by names: $error'),
  );

  /// Returns an author by [id], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorById(String id) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.authorsBox;
          final raw = box.get(id);
          return raw != null ? AuthorModel.fromMap(map: _cast(raw)) : null;
        },
        (error, _) => DatabaseFailure('Failed to get author by id: $error'),
      );

  /// Returns authors that match the given business ID [pair].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByBusinessIdPair(
    AuthorIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.authorsBox;
      return box.values
          .where((v) {
            final map = _cast(v);
            final raw = map['businessIds'] as List<dynamic>? ?? [];
            return raw.any((e) {
              final idType = AuthorIdType.values.byName(e['idType'] as String);
              return AuthorIdPair(
                    idType: idType,
                    idCode: e['idCode'] as String,
                  ) ==
                  pair;
            });
          })
          .map((v) => AuthorModel.fromMap(map: _cast(v)))
          .toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get authors by business id pair: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [author] in the box.
  TaskEither<Failure, Unit> saveAuthor(AuthorModel author) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.authorsBox;
          await box.put(author.id, author.toMap());
          return unit;
        },
        (error, _) => DatabaseFailure('Failed to save author: $error'),
      );

  /// Deletes the author with [id] from the box.
  TaskEither<Failure, Unit> deleteAuthor(String id) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.authorsBox;
      await box.delete(id);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete author: $error'),
  );

  /// Deletes all authors from the box.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.authorsBox;
      await box.clear();
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete all authors: $error'),
  );

  /// Deletes [authorId] and all books that reference it.
  TaskEither<Failure, Unit> deleteAuthorWithCascade(String authorId) =>
      TaskEither.tryCatch(
        () async {
          final authorsBox = await _hiveDb.authorsBox;
          final booksBox = await _hiveDb.booksBox;

          final rawAuthor = authorsBox.get(authorId);
          if (rawAuthor == null) throw const ServiceFailure('Author not found');
          final author = AuthorModel.fromMap(map: _cast(rawAuthor));

          // Delete books that list this author.
          final bookKeys = booksBox.keys.toList();
          for (final key in bookKeys) {
            final raw = booksBox.get(key);
            if (raw == null) continue;
            final book = BookModel.fromMap(map: _cast(raw));
            if (book.authorIds.contains(author.id)) {
              await booksBox.delete(key);
            }
          }
          await authorsBox.delete(author.id);
          return unit;
        },
        (error, _) => error is Failure
            ? error
            : DatabaseFailure('Failed to delete author with cascade: $error'),
      );
}
