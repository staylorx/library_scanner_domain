import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:domain_entities/domain_entities.dart';

import '../database/isar_database.dart';
import 'isar_transaction_handle.dart';

/// A [UnitOfWork] that is already *inside* an open Isar `writeTxn`.
///
/// Created by [IsarUnitOfWork.run] for the duration of an `isar.writeTxn`
/// callback.  Its [transactionHandle] exposes the live [IsarTransactionHandle]
/// so repositories can propagate it to nested operations.
///
/// Calling [run] on this class does **not** open a nested Isar transaction.
/// Isar does not support nested `writeTxn` calls — attempting one from the
/// same isolate throws.  Instead, the already-open transaction is re-used
/// by simply invoking the operation with `this`.
class IsarTransactionUnitOfWork implements UnitOfWork<IsarTransactionHandle> {
  @override
  final IsarTransactionHandle transactionHandle;

  const IsarTransactionUnitOfWork(this.transactionHandle);

  /// Runs [operation] within the already-open Isar write transaction.
  ///
  /// The same [IsarTransactionUnitOfWork] (`this`) is passed back so nested
  /// calls propagate the same handle without opening a new transaction.
  @override
  TaskEither<Failure, R> run<R>(
    TaskEither<Failure, R> Function(UnitOfWork<IsarTransactionHandle> txn)
    operation,
  ) =>
      operation(this);
}

/// The top-level Isar [UnitOfWork].
///
/// This is the "outer" unit of work — no transaction is open until [run] is
/// called.  Calling [run] opens an Isar `writeTxn`, wraps the live [Isar]
/// instance in an [IsarTransactionHandle], and invokes the operation inside
/// that transaction.
///
/// ## ACID guarantees
///
/// Isar provides **full ACID write transactions**:
///
/// - **Atomicity**: all writes in a `writeTxn` either all succeed or all fail.
/// - **Consistency**: Isar's schema constraints are enforced on commit.
/// - **Isolation**: the transaction operates on a snapshot; concurrent readers
///   see the committed state only after the transaction completes.
/// - **Durability**: committed data is flushed to disk by Isar's native layer.
///
/// If [operation] returns a `Left` (failure), this class **re-throws** the
/// [Failure] so Isar rolls back the entire transaction — no partial writes.
/// The failure is then caught and returned as a `Left` to the caller.
///
/// This is the identical pattern to [SembastUnitOfWork], proving the
/// [UnitOfWork] abstraction works with any ACID-capable backend unchanged.
///
/// ## commit / rollback
///
/// Manual [commit] and [rollback] are not part of Isar's public API —
/// transactions commit automatically on success and roll back on exception.
/// Both methods always return `Left(ServiceFailure)`.
class IsarUnitOfWork implements UnitOfWork<TransactionHandle> {
  final IsarDatabase isarDb;

  const IsarUnitOfWork({required this.isarDb});

  /// Always `null` — no transaction is open until [run] is called.
  @override
  TransactionHandle? get transactionHandle => null;

  /// Opens an Isar write transaction and runs [operation] inside it.
  ///
  /// The [operation] receives an [IsarTransactionUnitOfWork] whose handle
  /// wraps the live [Isar] instance.  Pass this `txn` to repository methods
  /// so they enlist in the same write transaction.
  ///
  /// The transaction commits on success and rolls back on any failure.
  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(UnitOfWork<TransactionHandle> txn)
    operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        T? result;
        final db = await isarDb.isar;
        await db.writeTxn(() async {
          final txn = IsarTransactionUnitOfWork(IsarTransactionHandle(db));
          final opResult = await operation(txn).run();
          // Re-throw on failure so Isar rolls back the transaction (real ACID!).
          result = opResult.fold((failure) => throw failure, (value) => value);
        });
        return result as T;
      },
      (error, _) =>
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  /// Not supported — Isar commits automatically on `writeTxn` success.
  TaskEither<Failure, Unit> commit() => TaskEither.left(
    const ServiceFailure(
      'Manual commit is not supported — Isar commits automatically on writeTxn success.',
    ),
  );

  /// Not supported — Isar rolls back automatically on exception.
  TaskEither<Failure, Unit> rollback() => TaskEither.left(
    const ServiceFailure(
      'Manual rollback is not supported — Isar rolls back automatically on failure.',
    ),
  );
}
