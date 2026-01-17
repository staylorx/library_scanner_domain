import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';

/// Abstract transaction interface for database operations.
abstract class Transaction {}

/// Abstract Unit of Work for managing transactions across repositories.
abstract class UnitOfWork {
  /// Runs an operation within a transaction.
  /// The operation receives a Transaction handle and returns a `Future<T>`.
  /// The transaction is committed if the operation succeeds, rolled back on failure.
  Future<Either<Failure, T>> run<T>(
    Future<T> Function(Transaction txn) operation,
  );

  /// Manually commits the current transaction.
  Future<Either<Failure, Unit>> commit();

  /// Manually rolls back the current transaction.
  Future<Either<Failure, Unit>> rollback();
}
