import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Sembast implementation of Transaction.
class SembastTransaction implements Transaction {
  @override
  final dynamic db;

  /// Creates a SembastTransaction with the database transaction handle.
  SembastTransaction(this.db);
}
