import 'package:fpdart/fpdart.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';

import '../unit_of_work/sembast_transaction.dart';
import '../datasources/sembast_database.dart';

/// Sembast implementation of UnitOfWork.
class SembastUnitOfWork implements UnitOfWork {
  final SembastDatabase sembastDb;

  /// Creates a SembastUnitOfWork with the required SembastDatabase.
  SembastUnitOfWork({required this.sembastDb});

  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(Transaction txn) operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        T? result;
        final db = await sembastDb.database;
        await db.transaction((txn) async {
          final opResult = await operation(SembastTransaction(txn)).run();
          result = opResult.fold((l) => throw l, (r) => r);
        });
        return result as T;
      },
      (error, stackTrace) =>
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, Unit> commit() {
    // Sembast transactions are auto-committed; manual commit not supported
    return TaskEither.left(
      ServiceFailure('Manual commit not supported in SembastUnitOfWork'),
    );
  }

  @override
  TaskEither<Failure, Unit> rollback() {
    // Sembast transactions are auto-rolled back on failure; manual rollback not supported
    return TaskEither.left(
      ServiceFailure('Manual rollback not supported in SembastUnitOfWork'),
    );
  }
}
