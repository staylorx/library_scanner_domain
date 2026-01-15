import 'package:library_scanner_domain/src/domain/repositories/unit_of_work.dart';

/// Sembast implementation of Transaction.
class SembastTransaction implements Transaction {
  final dynamic db;

  /// Creates a SembastTransaction with the database transaction handle.
  SembastTransaction(this.db);
}
