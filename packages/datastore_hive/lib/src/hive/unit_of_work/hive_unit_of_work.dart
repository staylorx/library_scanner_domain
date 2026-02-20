import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'hive_transaction_handle.dart';

/// A [UnitOfWork] that is already *inside* an open Hive logical transaction.
///
/// Created by [HiveUnitOfWork.run] for the duration of its callback.
/// Its [transactionHandle] exposes the live [HiveTransactionHandle] so
/// repositories can detect they are already enlisted in a unit of work.
///
/// Calling [run] on this class does **not** open a new transaction — it simply
/// re-uses the already-active handle by invoking the operation with `this`.
///
/// ## No nested transactions
///
/// Hive has no native transaction concept.  Re-using this handle for nested
/// operations is safe: each write still goes directly to the open box, and
/// the same single [HiveTransactionHandle] is propagated to all callers.
class HiveTransactionUnitOfWork implements UnitOfWork<HiveTransactionHandle> {
  @override
  final HiveTransactionHandle transactionHandle;

  const HiveTransactionUnitOfWork(this.transactionHandle);

  /// Runs [operation] within the already-active logical transaction.
  ///
  /// The same [HiveTransactionUnitOfWork] (`this`) is passed back so that
  /// nested calls propagate the same handle without creating a new one.
  @override
  TaskEither<Failure, R> run<R>(
    TaskEither<Failure, R> Function(UnitOfWork<HiveTransactionHandle> txn)
    operation,
  ) =>
      operation(this);
}

/// The top-level Hive [UnitOfWork].
///
/// This is the "outer" unit of work — no handle is open until [run] is called.
/// Calling [run] creates a [HiveTransactionHandle] placeholder, wraps it in a
/// [HiveTransactionUnitOfWork], and invokes the [operation] inside that context.
///
/// ## No ACID rollback
///
/// Hive does not support atomic multi-key transactions.  If [operation] returns
/// a `Left` (failure), all writes that have already been issued to Hive boxes
/// **are not rolled back**.  This is a known limitation of the Hive backend.
///
/// Callers that require strict atomicity should use the Sembast backend instead,
/// or implement compensating writes at the use-case layer.
///
/// ## commit / rollback
///
/// Manual [commit] and [rollback] are not meaningful for Hive.  Both methods
/// always return `Left(ServiceFailure)`.
class HiveUnitOfWork implements UnitOfWork<TransactionHandle> {
  const HiveUnitOfWork();

  /// Always `null` — no handle is open until [run] is called.
  @override
  TransactionHandle? get transactionHandle => null;

  /// Runs [operation] inside a logical Hive unit of work.
  ///
  /// The [operation] receives a [HiveTransactionUnitOfWork] whose
  /// [transactionHandle] is a [HiveTransactionHandle] placeholder.
  /// Pass this `txn` to repository methods so they can detect enlistment
  /// and avoid opening a redundant nested context.
  ///
  /// On success, the result is returned as `Right`.  On failure the
  /// `Left(Failure)` from the operation is preserved; any non-`Failure`
  /// exception is wrapped in [ServiceFailure].
  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(UnitOfWork<TransactionHandle> txn)
    operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        const handle = HiveTransactionHandle();
        const txn = HiveTransactionUnitOfWork(handle);
        final result = await operation(txn).run();
        return result.fold((failure) => throw failure, (value) => value);
      },
      (error, _) =>
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  /// Not supported — Hive writes are flushed individually, not on commit.
  ///
  /// Returns `Left(ServiceFailure)` always.
  TaskEither<Failure, Unit> commit() => TaskEither.left(
    const ServiceFailure(
      'Manual commit is not supported — Hive flushes writes individually.',
    ),
  );

  /// Not supported — Hive has no rollback mechanism.
  ///
  /// Returns `Left(ServiceFailure)` always.
  TaskEither<Failure, Unit> rollback() => TaskEither.left(
    const ServiceFailure(
      'Manual rollback is not supported — Hive has no transaction rollback.',
    ),
  );
}
