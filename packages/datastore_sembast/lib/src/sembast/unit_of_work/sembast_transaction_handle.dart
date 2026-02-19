import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

/// Wrapper that makes sembast.DatabaseClient implement TransactionHandle.
/// This allows Sembast's database client to be used as a transaction handle
/// in the domain's UnitOfWork abstraction.
class SembastTransactionHandle implements TransactionHandle {
  final sembast.DatabaseClient _dbClient;

  SembastTransactionHandle(this._dbClient);

  /// Gets the wrapped sembast DatabaseClient.
  sembast.DatabaseClient get dbClient => _dbClient;
}