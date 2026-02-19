import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Abstract Unit of Work for managing transactions across repositories.
abstract class UnitOfWork {
  /// Runs an operation within a transaction.
  /// The operation returns a `TaskEither<Failure, T>`.
  /// The transaction is committed if the operation succeeds, rolled back on failure.
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(UnitOfWork txn) operation,
  );

  /// Manually commits the current transaction.
  TaskEither<Failure, Unit> commit();

  /// Manually rolls back the current transaction.
  TaskEither<Failure, Unit> rollback();
}
