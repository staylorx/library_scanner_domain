import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import '../hive/unit_of_work/hive_transaction_handle.dart';

/// Base class for all Hive repository implementations.
///
/// Provides [runInTransaction], the single helper every repository uses to
/// execute datasource operations inside a logical Hive unit of work.
///
/// Repositories receive an optional `txn` parameter on each mutating method.
/// If `txn` is provided the operation joins the *caller's* active unit of work;
/// otherwise the repository's own [unitOfWork] is used to create a new one.
///
/// ## No real transactions
///
/// Hive does not support ACID transactions.  The [HiveTransactionHandle]
/// carried by the inner unit of work is a placeholder — it signals that we
/// are "inside" a logical transaction context, but individual writes are still
/// flushed to the Hive box independently.  Repositories extract this handle
/// so datasource methods can detect enlistment (e.g. for consistency in reads),
/// but there is no rollback on failure.
abstract class HiveBaseRepository {
  /// The repository's default [UnitOfWork].
  ///
  /// Used when no external `txn` is supplied to a mutating method.
  final UnitOfWork<TransactionHandle> unitOfWork;

  const HiveBaseRepository(this.unitOfWork);

  /// Runs [operation] inside a logical Hive unit of work.
  ///
  /// - If [txn] is provided, the operation joins that unit of work (no new
  ///   context is created).
  /// - If [txn] is `null`, [unitOfWork] creates a new logical context.
  ///
  /// The [operation] callback receives the [HiveTransactionHandle] that
  /// corresponds to the active context, or `null` if the active unit of work
  /// carries no handle (which should not happen in normal usage).
  TaskEither<Failure, R> runInTransaction<R>({
    required TaskEither<Failure, R> Function(HiveTransactionHandle? handle)
    operation,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final activeTxn = txn ?? unitOfWork;
    return activeTxn.run((UnitOfWork<TransactionHandle> t) {
      final handle = _handleOf(t.transactionHandle);
      return operation(handle);
    });
  }

  /// Extracts the [HiveTransactionHandle] from a [TransactionHandle].
  ///
  /// Returns `null` if [handle] is not a [HiveTransactionHandle] (which
  /// should only happen if a non-Hive unit of work is mixed in by mistake).
  HiveTransactionHandle? _handleOf(TransactionHandle? handle) =>
      handle is HiveTransactionHandle ? handle : null;
}
