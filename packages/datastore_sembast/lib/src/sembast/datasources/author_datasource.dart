import 'package:datastore_sembast/src/models/author_model.dart';
import 'package:datastore_sembast/src/models/book_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import 'sembast_database.dart';

class AuthorDatasource {
  final SembastDatabase _sembastDb;

  AuthorDatasource({required SembastDatabase sembastDb})
      : _sembastDb = sembastDb;

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all authors from the store.
  TaskEither<Failure, List<AuthorModel>> getAllAuthors() =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final records = await _sembastDb.authorsStore.find(db);
          return records
              .map((r) => AuthorModel.fromMap(map: r.value))
              .toList();
        },
        (error, _) => DatabaseFailure('Failed to get all authors: $error'),
      );

  /// Returns an author matching [name], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorByName(String name) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final finder = sembast.Finder(
            filter: sembast.Filter.equals('name', name),
          );
          final records =
              await _sembastDb.authorsStore.find(db, finder: finder);
          return records.isEmpty
              ? null
              : AuthorModel.fromMap(map: records.first.value);
        },
        (error, _) => DatabaseFailure('Failed to get author by name: $error'),
      );

  /// Returns authors whose names are in [names].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByNames(
    List<String> names,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.inList('name', names),
      );
      final records = await _sembastDb.authorsStore.find(db, finder: finder);
      return records.map((r) => AuthorModel.fromMap(map: r.value)).toList();
    },
    (error, _) => DatabaseFailure('Failed to get authors by names: $error'),
  );

  /// Returns an author by [id], or `null` if not found.
  TaskEither<Failure, AuthorModel?> getAuthorById(String id) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final record = await _sembastDb.authorsStore.record(id).get(db);
          return record != null ? AuthorModel.fromMap(map: record) : null;
        },
        (error, _) => DatabaseFailure('Failed to get author by id: $error'),
      );

  /// Returns authors that match the given business ID [pair].
  TaskEither<Failure, List<AuthorModel>> getAuthorsByBusinessIdPair(
    AuthorIdPair pair,
  ) => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          final raw = record['businessIds'] as List<dynamic>? ?? [];
          return raw.any((e) {
            final idType = AuthorIdType.values.byName(e['idType'] as String);
            return AuthorIdPair(idType: idType, idCode: e['idCode'] as String) ==
                pair;
          });
        }),
      );
      final records = await _sembastDb.authorsStore.find(db, finder: finder);
      return records.map((r) => AuthorModel.fromMap(map: r.value)).toList();
    },
    (error, _) =>
        DatabaseFailure('Failed to get authors by business id pair: $error'),
  );

  // ─── Write operations ─────────────────────────────────────────────────────

  /// Inserts or replaces [author] in the store.
  TaskEither<Failure, Unit> saveAuthor(
    AuthorModel author, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.authorsStore.record(author.id).put(db, author.toMap());
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save author: $error'),
  );

  /// Deletes the author with [id] from the store.
  TaskEither<Failure, Unit> deleteAuthor(
    String id, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.authorsStore.record(id).delete(db);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete author: $error'),
  );

  /// Deletes all authors from the store.
  TaskEither<Failure, Unit> deleteAll({sembast.DatabaseClient? txn}) =>
      TaskEither.tryCatch(
        () async {
          final db = txn ?? await _sembastDb.database;
          await _sembastDb.authorsStore.delete(db);
          return unit;
        },
        (error, _) => DatabaseFailure('Failed to delete all authors: $error'),
      );

  /// Deletes [authorId] and all books that reference it.
  ///
  /// This cascade delete is performed within [txn] (or a fresh database
  /// connection if [txn] is `null`).
  TaskEither<Failure, Unit> deleteAuthorWithCascade(
    String authorId, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      final rawAuthor =
          await _sembastDb.authorsStore.record(authorId).get(db);
      if (rawAuthor == null) throw const ServiceFailure('Author not found');
      final author = AuthorModel.fromMap(map: rawAuthor);
      // Delete books that list this author.
      final bookRecords = await _sembastDb.booksStore.find(db);
      for (final bookRecord in bookRecords) {
        final book = BookModel.fromMap(map: bookRecord.value);
        if (book.authorIds.contains(author.id)) {
          await _sembastDb.booksStore.record(book.id).delete(db);
        }
      }
      await _sembastDb.authorsStore.record(author.id).delete(db);
      return unit;
    },
    (error, _) => error is Failure
        ? error
        : DatabaseFailure('Failed to delete author with cascade: $error'),
  );
}
