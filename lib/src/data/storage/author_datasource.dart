import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';

class AuthorDatasource {
  final DatabaseService _dbService;

  /// Creates a datasource with required DatabaseService and BookDatasource.
  AuthorDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  /// Retrieves all authors from the store.
  Future<Either<Failure, List<AuthorModel>>> getAllAuthors() async {
    try {
      final result = await _dbService.getAll(collection: 'authors');
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => AuthorModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get all authors: $e'));
    }
  }

  /// Retrieves an author by name.
  Future<Either<Failure, AuthorModel?>> getAuthorByName(String name) async {
    try {
      final result = await _dbService.query(
        collection: 'authors',
        filter: {'name': name},
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(AuthorModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get author by name: $e'));
    }
  }

  /// Retrieves authors by a list of names.
  Future<Either<Failure, List<AuthorModel>>> getAuthorsByNames(
    List<String> names,
  ) async {
    try {
      final result = await _dbService.query(
        collection: 'authors',
        filter: {
          'name': {'\$in': names},
        },
      );
      return result.match((failure) => Either.left(failure), (records) {
        return Either.right(
          records.map((record) => AuthorModel.fromMap(map: record)).toList(),
        );
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get authors by names: $e'));
    }
  }

  /// Retrieves an author by ID.
  Future<Either<Failure, AuthorModel?>> getAuthorById(String id) async {
    try {
      final result = await _dbService.query(
        collection: 'authors',
        filter: {'id': id},
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(AuthorModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get author by ID: $e'));
    }
  }

  /// Saves an author to the store.
  Future<Either<Failure, Unit>> saveAuthor(
    AuthorModel author, {
    dynamic db,
  }) async {
    try {
      final data = author.toMap();
      final result = await _dbService.save(
        collection: 'authors',
        id: author.id,
        data: data,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to save author: $e'));
    }
  }

  /// Deletes an author by ID.
  Future<Either<Failure, Unit>> deleteAuthor(String id, {dynamic db}) async {
    try {
      final result = await _dbService.delete(
        collection: 'authors',
        id: id,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to delete author: $e'));
    }
  }

  /// Deletes an author.
  Future<Either<Failure, Unit>> deleteAuthorWithCascade(
    String authorName, {
    dynamic db,
  }) async {
    try {
      // Delete the author
      final deleteAuthorResult = await deleteAuthor(authorName, db: db);
      return deleteAuthorResult;
    } catch (e) {
      return Either.left(
        ServiceFailure('Failed to delete author with cascade: $e'),
      );
    }
  }

  /// Executes a transaction with the given operation.
  Future<Either<Failure, Unit>> transaction(
    Future<Unit> Function(dynamic txn) operation,
  ) async {
    final result = await _dbService.transaction(operation: operation);
    return result.map((_) => unit);
  }
}
