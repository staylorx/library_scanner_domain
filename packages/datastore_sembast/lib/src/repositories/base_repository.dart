import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import '../sembast/unit_of_work/sembast_transaction_handle.dart';

/// Base class for all Sembast repository implementations.
///
/// Provides [runInTransaction], the single helper every repository uses to
/// execute datasource operations inside an atomic Sembast transaction.
///
/// Repositories receive an optional `txn` parameter on each mutating method.
/// If `txn` is provided the operation joins the *caller's* open transaction;
/// otherwise the repository's own [unitOfWork] is used to open a new one.
abstract class SembastBaseRepository {
  /// The repository's default [UnitOfWork].
  ///
  /// Used when no external `txn` is supplied to a mutating method.
  final UnitOfWork<TransactionHandle> unitOfWork;

  const SembastBaseRepository(this.unitOfWork);

  /// Runs [operation] inside an atomic Sembast transaction.
  ///
  /// - If [txn] is provided, the operation joins that transaction (no new
  ///   transaction is opened).
  /// - If [txn] is `null`, [unitOfWork] opens a new transaction.
  ///
  /// The [operation] callback receives the raw `sembast.DatabaseClient` that
  /// corresponds to the open transaction (or `null` if the active unit of work
  /// somehow carries no handle, which should not happen in normal usage).
  TaskEither<Failure, R> runInTransaction<R>({
    required TaskEither<Failure, R> Function(sembast.DatabaseClient? dbClient)
    operation,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final activeTxn = txn ?? unitOfWork;
    return activeTxn.run((UnitOfWork<TransactionHandle> t) {
      final dbClient = _dbClientOf(t.transactionHandle);
      return operation(dbClient);
    });
  }

  /// Extracts the [sembast.DatabaseClient] from a [TransactionHandle].
  ///
  /// Returns `null` if [handle] is not a [SembastTransactionHandle] (which
  /// should only happen if a non-Sembast implementation is mixed in by mistake).
  sembast.DatabaseClient? _dbClientOf(TransactionHandle? handle) =>
      handle is SembastTransactionHandle ? handle.dbClient : null;
}
