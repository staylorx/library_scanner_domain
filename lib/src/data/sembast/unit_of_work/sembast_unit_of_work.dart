import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';

/// Sembast implementation of UnitOfWork.
class SembastUnitOfWork implements UnitOfWork {
  final DatabaseService _dbService;

  /// Creates a SembastUnitOfWork with the required DatabaseService.
  SembastUnitOfWork({required DatabaseService dbService})
    : _dbService = dbService;

  @override
  Future<Either<Failure, T>> run<T>(
    Future<T> Function(Transaction txn) operation,
  ) async {
    T? result;
    final txnResult = await _dbService.transaction(
      operation: (txn) async {
        result = await operation(SembastTransaction(txn));
        return unit;
      },
    );
    return txnResult.map((_) => result as T);
  }

  @override
  Future<Either<Failure, Unit>> commit() async {
    // Sembast transactions are auto-committed; manual commit not supported
    return Left(
      ServiceFailure('Manual commit not supported in SembastUnitOfWork'),
    );
  }

  @override
  Future<Either<Failure, Unit>> rollback() async {
    // Sembast transactions are auto-rolled back on failure; manual rollback not supported
    return Left(
      ServiceFailure('Manual rollback not supported in SembastUnitOfWork'),
    );
  }
}
