import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import '../sembast/unit_of_work/sembast_transaction_handle.dart';

/// Base class for Sembast repositories providing common transaction handling.
abstract class SembastBaseRepository {
  final UnitOfWork<TransactionHandle> unitOfWork;

  const SembastBaseRepository(this.unitOfWork);

  /// Returns the effective transaction (provided or default).
  UnitOfWork<TransactionHandle> effectiveTransaction(
    UnitOfWork<TransactionHandle>? txn,
  ) =>
      txn ?? unitOfWork;

  /// Extracts the sembast.DatabaseClient from a transaction handle, if any.
  /// Returns null if the handle is not a SembastTransactionHandle.
  sembast.DatabaseClient? dbClientFromHandle(TransactionHandle? handle) {
    if (handle is SembastTransactionHandle) {
      return handle.dbClient;
    }
    return null;
  }

  /// Executes an operation within a transaction, using the provided or default unit of work.
  /// The operation receives a sembast.DatabaseClient? (the transaction client, if any).
  TaskEither<Failure, R> runInTransaction<R>({
    required TaskEither<Failure, R> Function(sembast.DatabaseClient? dbClient) operation,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final effectiveTxn = effectiveTransaction(txn);
    return effectiveTxn.run((UnitOfWork<TransactionHandle> t) {
      final dbClient = dbClientFromHandle(t.transactionHandle);
      return operation(dbClient);
    });
  }

  /// Convenience method for repository methods that need to call a datasource with transaction.
  /// This pattern matches the common usage: get effective transaction, run operation, pass dbClient.
  TaskEither<Failure, R> withTransaction<R>({
    required TaskEither<Failure, R> Function(sembast.DatabaseClient? dbClient) datasourceOperation,
    UnitOfWork<TransactionHandle>? txn,
  }) =>
      runInTransaction(operation: datasourceOperation, txn: txn);
}