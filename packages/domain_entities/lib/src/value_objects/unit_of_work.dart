import 'package:fpdart/fpdart.dart';
import '../utils/failure.dart';
import '../utils/transaction_handle.dart';

/// A domain-level abstraction for a transactional unit of work.
///
/// [UnitOfWork] allows domain usecases to coordinate multiple repository
/// operations within a single atomic transaction, without depending on any
/// specific database technology.
///
/// ## Usage pattern
///
/// A usecase receives a [UnitOfWork] and opens a transaction via [run].
/// The callback receives the *active* unit of work (with a live transaction
/// handle inside), which it passes as `txn` to each repository operation:
///
/// ```dart
/// return unitOfWork.run((txn) =>
///   authorRepository.create(item: author, txn: txn).flatMap((_) =>
///     bookRepository.create(item: book, txn: txn)));
/// ```
///
/// Repositories that receive a non-null `txn` join that open transaction.
/// Repositories that receive `null` start and manage their own transaction.
///
/// ## Type parameter
///
/// [T] is the infrastructure-specific transaction handle type (e.g.
/// `SembastTransactionHandle`). Domain code uses the base bound
/// [TransactionHandle]; infrastructure code uses the concrete type.
abstract class UnitOfWork<T extends TransactionHandle> {
  /// The live, infrastructure-specific transaction handle.
  ///
  /// Returns `null` if no transaction is currently open (i.e. this is the
  /// "outer" unit of work that has not yet started a transaction).
  T? get transactionHandle;

  /// Executes [operation] inside an atomic transaction.
  ///
  /// The callback receives an [UnitOfWork] whose [transactionHandle] is
  /// guaranteed to be non-null — it represents the currently open transaction.
  /// Pass this to repository `txn` parameters to enlist them in the same
  /// transaction.
  ///
  /// Returns `Right(result)` if the operation succeeds; the transaction is
  /// committed automatically.
  ///
  /// Returns `Left(failure)` if the operation fails or throws; the
  /// transaction is rolled back automatically.
  TaskEither<Failure, R> run<R>(
    TaskEither<Failure, R> Function(UnitOfWork<T> txn) operation,
  );
}
