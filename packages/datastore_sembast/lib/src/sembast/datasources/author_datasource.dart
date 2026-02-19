import 'package:datastore_sembast/src/models/author_model.dart';
import 'package:datastore_sembast/src/models/book_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import 'sembast_database.dart';
import '../unit_of_work/sembast_transaction.dart';

class AuthorDatasource {
  final SembastDatabase _sembastDb;

  /// Creates an AuthorDatasource with required SembastDatabase.
  AuthorDatasource({required SembastDatabase sembastDb}) : _sembastDb = sembastDb;

  /// Retrieves all authors from the store.
  TaskEither<Failure, List<AuthorModel>> getAllAuthors() {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final records = await _sembastDb.authorsStore.find(db);
      return records.map((r) => AuthorModel.fromMap(map: r.value)).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get all authors: $error'));
  }

  /// Retrieves an author by name.
  TaskEither<Failure, AuthorModel?> getAuthorByName(String name) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(filter: sembast.Filter.equals('name', name));
      final records = await _sembastDb.authorsStore.find(db, finder: finder);
      if (records.isEmpty) return null;
      return AuthorModel.fromMap(map: records.first.value);
    }, (error, stackTrace) => DatabaseFailure('Failed to get author by name: $error'));
  }

  /// Retrieves authors by a list of names.
  TaskEither<Failure, List<AuthorModel>> getAuthorsByNames(List<String> names) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final namesList = names.toList();
      final finder = sembast.Finder(
        filter: sembast.Filter.inList('name', namesList),
      );
      final records = await _sembastDb.authorsStore.find(db, finder: finder);
      return records.map((r) => AuthorModel.fromMap(map: r.value)).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get authors by names: $error'));
  }

  /// Retrieves an author by ID.
  TaskEither<Failure, AuthorModel?> getAuthorById(String id) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final record = await _sembastDb.authorsStore.record(id).get(db);
      return record != null ? AuthorModel.fromMap(map: record) : null;
    }, (error, stackTrace) => DatabaseFailure('Failed to get author by id: $error'));
  }

  /// Retrieves authors by business ID pair.
  TaskEither<Failure, List<AuthorModel>> getAuthorsByBusinessIdPair(
    AuthorIdPair pair,
  ) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          final businessIdsRaw = record['businessIds'] as List<dynamic>? ?? [];
          final businessIds = businessIdsRaw.map((e) {
            final idTypeString = e['idType'] as String;
            final idType = AuthorIdType.values.byName(idTypeString);
            return AuthorIdPair(
              idType: idType,
              idCode: e['idCode'] as String,
            );
          }).toList();
          return businessIds.any((p) => p == pair);
        }),
      );
      final records = await _sembastDb.authorsStore.find(db, finder: finder);
      return records.map((r) => AuthorModel.fromMap(map: r.value)).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get authors by business id pair: $error'));
  }

  /// Saves an author to the store.
  TaskEither<Failure, Unit> saveAuthor(AuthorModel author, {Transaction? txn}) {
    return TaskEither.tryCatch(() async {
      final data = author.toMap();
      final db = txn?.db as sembast.Database? ?? await _sembastDb.database;
      await _sembastDb.authorsStore.record(author.id).put(db, data);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to save author: $error'));
  }

  /// Deletes an author by ID.
  TaskEither<Failure, Unit> deleteAuthor(String id, {Transaction? txn}) {
    return TaskEither.tryCatch(() async {
      final db = txn?.db as sembast.Database? ?? await _sembastDb.database;
      await _sembastDb.authorsStore.record(id).delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to delete author: $error'));
  }

  /// Deletes an author with cascade deletion of associated books.
  TaskEither<Failure, Unit> deleteAuthorWithCascade(
    String authorId, {
    Transaction? txn,
  }) {
    return TaskEither.tryCatch(() async {
      final db = txn?.db as sembast.Database? ?? await _sembastDb.database;
      final authorRecord = await _sembastDb.authorsStore.record(authorId).get(db);
      if (authorRecord == null) {
        throw ServiceFailure('Author not found');
      }
      final author = AuthorModel.fromMap(map: authorRecord);
      final id = author.id;
      // Find and delete books with this author
      final bookRecords = await _sembastDb.booksStore.find(db);
      for (final bookRecord in bookRecords) {
        final book = BookModel.fromMap(map: bookRecord.value);
        if (book.authorIds.contains(id)) {
          await _sembastDb.booksStore.record(book.id).delete(db);
        }
      }
      await _sembastDb.authorsStore.record(id).delete(db);
      return unit;
    }, (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete author with cascade: $error'));
  }

  /// Executes a transaction with the given operation.
  TaskEither<Failure, Unit> transaction(
    Future<Unit> Function(dynamic txn) operation,
  ) {
    return TaskEither.tryCatch(() async {
      final db = await _sembastDb.database;
      await db.transaction((txn) async {
        await operation(SembastTransaction(txn));
      });
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Transaction failed: $error'));
  }
}
