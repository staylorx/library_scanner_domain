import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';

class AuthorDatasource {
  final DatabaseService _dbService;

  /// Creates an AuthorDatasource with required DatabaseService.
  AuthorDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  /// Retrieves all authors from the store.
  TaskEither<Failure, List<AuthorModel>> getAllAuthors() {
    return _dbService
        .getAll(collection: 'authors')
        .map(
          (records) => records
              .map((record) => AuthorModel.fromMap(map: record))
              .toList(),
        );
  }

  /// Retrieves an author by name.
  TaskEither<Failure, AuthorModel?> getAuthorByName(String name) {
    return _dbService.query(collection: 'authors', filter: {'name': name}).map((
      records,
    ) {
      if (records.isEmpty) {
        return null;
      }
      return AuthorModel.fromMap(map: records.first);
    });
  }

  /// Retrieves authors by a list of names.
  TaskEither<Failure, List<AuthorModel>> getAuthorsByNames(List<String> names) {
    return _dbService
        .query(
          collection: 'authors',
          filter: {
            'name': {'\$in': names},
          },
        )
        .map((records) {
          return records
              .map((record) => AuthorModel.fromMap(map: record))
              .toList();
        });
  }

  /// Retrieves an author by ID.
  TaskEither<Failure, AuthorModel?> getAuthorById(String id) {
    return _dbService.query(collection: 'authors', filter: {'id': id}).map((
      records,
    ) {
      if (records.isEmpty) {
        return null;
      }
      return AuthorModel.fromMap(map: records.first);
    });
  }

  /// Retrieves authors by business ID pair.
  TaskEither<Failure, List<AuthorModel>> getAuthorsByBusinessIdPair(
    AuthorIdPair pair,
  ) {
    return _dbService
        .query(
          collection: 'authors',
          filter: {
            '\$custom': (record) {
              final businessIdsRaw =
                  record.value['businessIds'] as List<dynamic>? ?? [];
              final businessIds = businessIdsRaw.map((e) {
                final idTypeString = e['idType'] as String;
                final idType = AuthorIdType.values.byName(idTypeString);
                return AuthorIdPair(
                  idType: idType,
                  idCode: e['idCode'] as String,
                );
              }).toList();
              return businessIds.any((p) => p == pair);
            },
          },
        )
        .map((records) {
          return records
              .map((record) => AuthorModel.fromMap(map: record))
              .toList();
        });
  }

  /// Saves an author to the store.
  TaskEither<Failure, Unit> saveAuthor(AuthorModel author, {Transaction? txn}) {
    return _dbService.save(
      collection: 'authors',
      id: author.id,
      data: author.toMap(),
      db: txn?.db,
    );
  }

  /// Deletes an author by ID.
  TaskEither<Failure, Unit> deleteAuthor(String id, {Transaction? txn}) {
    return _dbService.delete(collection: 'authors', id: id, db: txn?.db);
  }

  /// Deletes an author with cascade deletion of associated books.
  TaskEither<Failure, Unit> deleteAuthorWithCascade(
    String authorId, {
    Transaction? txn,
  }) {
    return _dbService
        .query(collection: 'authors', filter: {'id': authorId}, db: txn?.db)
        .flatMap((records) {
          if (records.isEmpty) {
            return TaskEither.left(ServiceFailure('Author not found'));
          }
          final author = AuthorModel.fromMap(map: records.first);
          final id = author.id;
          return _dbService
              .query(collection: 'books', filter: {'authorId': id}, db: txn?.db)
              .flatMap((bookRecords) {
                final deleteBookTasks = bookRecords.map(
                  (record) => _dbService.delete(
                    collection: 'books',
                    id: record['id'] as String,
                    db: txn?.db,
                  ),
                );
                final initial = TaskEither<Failure, Unit>.of(unit);
                final deleteAllBooks = deleteBookTasks.fold(
                  initial,
                  (acc, task) => acc.flatMap((_) => task),
                );
                return deleteAllBooks.flatMap((_) {
                  return _dbService.delete(
                    collection: 'authors',
                    id: id,
                    db: txn?.db,
                  );
                });
              });
        });
  }

  /// Executes a transaction with the given operation.
  TaskEither<Failure, Unit> transaction(
    Future<Unit> Function(Transaction txn) operation,
  ) {
    return _dbService.transaction(
      operation: (dynamicTxn) => operation(SembastTransaction(dynamicTxn)),
    );
  }
}
