import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import '../datasources/sembast_database.dart';
import 'sembast_transaction_handle.dart';

/// A [UnitOfWork] that is already *inside* an open Sembast transaction.
///
/// Created by [SembastUnitOfWork.run] for the duration of a `db.transaction`
/// callback. Its [transactionHandle] exposes the live [SembastTransactionHandle]
/// so repositories can pass it down to datasource calls.
///
/// Calling [run] on this class does NOT open a nested Sembast transaction — it
/// simply re-uses the already-open one by invoking the operation with `this`.
/// This is the correct Sembast behaviour: nested transactions are not supported,
/// and re-using the same transaction client is safe.
class SembastTransactionUnitOfWork
    implements UnitOfWork<SembastTransactionHandle> {
  @override
  final SembastTransactionHandle transactionHandle;

  SembastTransactionUnitOfWork(this.transactionHandle);

  /// Runs [operation] within the already-open transaction.
  ///
  /// The same [SembastTransactionUnitOfWork] (`this`) is passed back so that
  /// nested calls can propagate the transaction handle without opening a new
  /// transaction.
  @override
  TaskEither<Failure, R> run<R>(
    TaskEither<Failure, R> Function(UnitOfWork<SembastTransactionHandle> txn)
    operation,
  ) =>
      operation(this);
}

/// The top-level Sembast [UnitOfWork].
///
/// This is the "outer" unit of work — it has no open transaction yet.
/// Calling [run] opens a Sembast database transaction, wraps the Sembast
/// transaction client in a [SembastTransactionHandle], and invokes the
/// operation inside that transaction.
///
/// ## Auto-commit / auto-rollback
///
/// Sembast transactions are **auto-committed** when the `db.transaction`
/// callback completes normally and **auto-rolled-back** when it throws.
/// This class exploits that: if the [operation] returns a `Left` (failure),
/// it re-throws the [Failure] so Sembast rolls back, then catches it and
/// re-wraps it as a `Left` for the caller.
///
/// Manual [commit] and [rollback] are not supported by Sembast — calls to
/// those methods always return a `Left(ServiceFailure)`.
class SembastUnitOfWork implements UnitOfWork<TransactionHandle> {
  final SembastDatabase sembastDb;

  SembastUnitOfWork({required this.sembastDb});

  /// Always `null` — no transaction is open until [run] is called.
  @override
  TransactionHandle? get transactionHandle => null;

  /// Opens a Sembast database transaction and runs [operation] inside it.
  ///
  /// The [operation] receives a [SembastTransactionUnitOfWork] whose
  /// [transactionHandle] wraps the live Sembast `DatabaseClient`. Pass this
  /// `txn` to repository methods so they enlist in the same transaction.
  ///
  /// The transaction is committed on success and rolled back on any failure.
  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(UnitOfWork<TransactionHandle> txn)
    operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        T? result;
        final db = await sembastDb.database;
        await db.transaction((rawTxn) async {
          final txn = SembastTransactionUnitOfWork(
            SembastTransactionHandle(rawTxn),
          );
          final opResult = await operation(txn).run();
          // Re-throw on failure so Sembast rolls back the transaction.
          result = opResult.fold((failure) => throw failure, (value) => value);
        });
        return result as T;
      },
      (error, stackTrace) =>
          // Preserve domain Failure types; wrap anything else as ServiceFailure.
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  /// Not supported — Sembast transactions commit automatically on success.
  ///
  /// Returns `Left(ServiceFailure)` always. Prefer letting [run] handle
  /// commit via normal completion.
  TaskEither<Failure, Unit> commit() => TaskEither.left(
    const ServiceFailure(
      'Manual commit is not supported — Sembast commits automatically.',
    ),
  );

  /// Not supported — Sembast transactions roll back automatically on failure.
  ///
  /// Returns `Left(ServiceFailure)` always. Prefer letting [run] propagate
  /// failures which trigger automatic rollback.
  TaskEither<Failure, Unit> rollback() => TaskEither.left(
    const ServiceFailure(
      'Manual rollback is not supported — Sembast rolls back on failure.',
    ),
  );
}
