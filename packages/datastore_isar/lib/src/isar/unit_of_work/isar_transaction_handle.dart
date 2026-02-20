import 'package:isar/isar.dart';
import 'package:domain_entities/domain_entities.dart';

/// Wraps an open [Isar] instance and implements [TransactionHandle].
///
/// When [IsarUnitOfWork.run] opens an Isar `writeTxn`, it creates this handle
/// and passes it (via [IsarTransactionUnitOfWork]) to the operation callback.
///
/// ## Why carry the Isar instance?
///
/// Isar tracks the active write transaction **internally per isolate** — any
/// `isar.collection.put()` call issued while a `writeTxn` is in progress
/// automatically joins that transaction.  The [isar] reference here serves
/// two purposes:
///
/// 1. Repository-level helpers can resolve the live instance without a
///    separate database lookup (minor performance gain).
/// 2. It explicitly signals "we are enlisted in a live Isar write transaction"
///    rather than operating outside one.
///
/// Datasources do **not** need to extract [isar] from the handle — they hold
/// a reference to [IsarDatabase] and call through to [IsarDatabase.isar]
/// which returns the same instance.  Isar's internal state ensures they join
/// the correct transaction automatically.
class IsarTransactionHandle implements TransactionHandle {
  /// The open [Isar] instance currently inside a `writeTxn`.
  final Isar isar;

  const IsarTransactionHandle(this.isar);
}
