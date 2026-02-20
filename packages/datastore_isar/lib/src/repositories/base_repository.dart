import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import '../isar/unit_of_work/isar_transaction_handle.dart';

/// Base class for all Isar repository implementations.
///
/// Provides [runInTransaction], mirroring [SembastBaseRepository] exactly.
///
/// ## Why datasources need no special client
///
/// Isar tracks the active write transaction **internally per isolate**.  Any
/// collection operation (`put`, `get`, `delete`) called while a `writeTxn`
/// is open automatically joins that transaction — no "db client" parameter
/// needs to be threaded through the call stack.
///
/// The [IsarTransactionHandle] carried in the inner unit of work is still
/// meaningful: it signals to callers that they are within a write transaction
/// and provides the live [Isar] instance for cases where it is convenient
/// (e.g. repositories that need to open a sub-collection).  Datasources
/// that simply call through [IsarDatabase.isar] can safely ignore it.
abstract class IsarBaseRepository {
  /// The repository's default [UnitOfWork].
  final UnitOfWork<TransactionHandle> unitOfWork;

  const IsarBaseRepository(this.unitOfWork);

  /// Runs [operation] inside an Isar write transaction.
  ///
  /// - If [txn] is provided the operation joins that transaction (no new
  ///   `writeTxn` is opened — Isar would throw if nested).
  /// - If [txn] is `null`, [unitOfWork] opens a new `writeTxn`.
  ///
  /// The [operation] callback receives the [IsarTransactionHandle] from the
  /// active unit of work (or `null` if the handle is not an Isar handle,
  /// which should never happen in normal usage).
  TaskEither<Failure, R> runInTransaction<R>({
    required TaskEither<Failure, R> Function(IsarTransactionHandle? handle)
    operation,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final activeTxn = txn ?? unitOfWork;
    return activeTxn.run((UnitOfWork<TransactionHandle> t) {
      final handle = _handleOf(t.transactionHandle);
      return operation(handle);
    });
  }

  IsarTransactionHandle? _handleOf(TransactionHandle? handle) =>
      handle is IsarTransactionHandle ? handle : null;
}
