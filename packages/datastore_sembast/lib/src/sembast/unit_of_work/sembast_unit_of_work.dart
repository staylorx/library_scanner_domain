import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import '../datasources/sembast_database.dart';

/// UnitOfWork that wraps a Sembast transaction handle.
/// Used to pass transaction context to repository operations.
class SembastTransactionUnitOfWork implements UnitOfWork<sembast.DatabaseClient> {
  final sembast.DatabaseClient _transactionHandle;

  SembastTransactionUnitOfWork(this._transactionHandle);

  @override
  sembast.DatabaseClient get transactionHandle => _transactionHandle;

  @override
  TaskEither<Failure, R> run<R>(TaskEither<Failure, R> Function(UnitOfWork<sembast.DatabaseClient> txn) operation) {
    // Already inside a transaction, just execute operation with this context
    return operation(this);
  }

  @override
  R? maybeHandle<R extends Object?>() {
    final handle = transactionHandle;
    return handle is R ? handle as R : null;
  }

  @override
  bool hasHandle<R extends Object?>() => transactionHandle is R;
}

/// Sembast implementation of UnitOfWork.
class SembastUnitOfWork implements UnitOfWork<Object?> {
  final SembastDatabase sembastDb;

  /// Creates a SembastUnitOfWork with the required SembastDatabase.
  SembastUnitOfWork({required this.sembastDb});

  @override
  Object? get transactionHandle => null; // Sembast doesn't use a persistent handle

  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(UnitOfWork<Object?> txn) operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        T? result;
        final db = await sembastDb.database;
        await db.transaction((txn) async {
          final transactionUnitOfWork = SembastTransactionUnitOfWork(txn);
          final opResult = await operation(transactionUnitOfWork).run();
          result = opResult.fold((l) => throw l, (r) => r);
        });
        return result as T;
      },
      (error, stackTrace) =>
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  @override
  R? maybeHandle<R extends Object?>() => null;

  @override
  bool hasHandle<R extends Object?>() => false;

  TaskEither<Failure, Unit> commit() {
    // Sembast transactions are auto-committed; manual commit not supported
    return TaskEither.left(
      ServiceFailure('Manual commit not supported in SembastUnitOfWork'),
    );
  }

  TaskEither<Failure, Unit> rollback() {
    // Sembast transactions are auto-rolled back on failure; manual rollback not supported
    return TaskEither.left(
      ServiceFailure('Manual rollback not supported in SembastUnitOfWork'),
    );
  }
}
