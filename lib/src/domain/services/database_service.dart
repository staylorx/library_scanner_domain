import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract interface for a generic database service providing basic CRUD operations and transaction support.
abstract class DatabaseService {
  /// Saves data to the specified collection with the given id.
  Future<Either<Failure, Unit>> save({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    dynamic db,
  });

  /// Retrieves data from the specified collection by id.
  Future<Either<Failure, Map<String, dynamic>?>> get({
    required String collection,
    required String id,
  });

  /// Retrieves all data from the specified collection.
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({
    required String collection,
    int? limit,
    int? offset,
    dynamic db,
  });

  /// Queries data from the specified collection with filters.
  Future<Either<Failure, List<Map<String, dynamic>>>> query({
    required String collection,
    required Map<String, dynamic> filter,
    int? limit,
    int? offset,
    dynamic db,
  });

  /// Deletes data from the specified collection by id.
  Future<Either<Failure, Unit>> delete({
    required String collection,
    required String id,
    dynamic db,
  });

  /// Clears all data from the specified collection.
  Future<Either<Failure, Unit>> clear({required String collection});

  /// Clears all data from all collections.
  Future<Either<Failure, Unit>> clearAll();

  /// Executes a transaction with the given operation.
  Future<Either<Failure, Unit>> transaction({
    required Future<Unit> Function(dynamic txn) operation,
  });

  /// Closes the database connection.
  Future<Either<Failure, Unit>> close();
}
