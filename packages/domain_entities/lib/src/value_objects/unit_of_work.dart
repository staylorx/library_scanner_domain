import 'package:fpdart/fpdart.dart';
import '../utils/failure.dart';

/// Represents a unit of work in the domain, encapsulating a set of operations that should be treated as a single transaction.
/// The generic type [T] represents the infrastructure-specific transaction handle (defaults to Object?).
/// Domain code uses UnitOfWork without caring about the handle; infrastructure can attach a handle when needed.
abstract class UnitOfWork<T extends Object?> {
  /// The infrastructure-specific transaction handle, if any.
  T? get transactionHandle;

  /// Executes an operation within the unit of work transaction.
  /// The operation receives a UnitOfWork representing the transaction context and returns a TaskEither.
  TaskEither<Failure, R> run<R>(TaskEither<Failure, R> Function(UnitOfWork<T> txn) operation);

  /// Returns the transaction handle cast to [R], or null if the handle is not of type [R].
  R? maybeHandle<R extends Object?>();

  /// Returns true if this UnitOfWork has a transaction handle of type [R].
  bool hasHandle<R extends Object?>();
}
