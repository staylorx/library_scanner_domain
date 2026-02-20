import 'package:domain_entities/domain_entities.dart';

/// Marker that makes a Hive "transaction context" implement [TransactionHandle].
///
/// Hive does not support ACID transactions.  This handle is a **no-op**
/// placeholder: it carries no actual database client.  Repositories receive it
/// so they can detect that they are operating "inside" a logical unit of work,
/// but all writes go directly to the open Hive boxes.
///
/// Limitation: if a sequence of writes fails partway through there is no
/// automatic rollback.  Each write is individually flushed to disk by Hive's
/// own internal mechanism.  For the purposes of this implementation this is an
/// accepted trade-off documented here so callers are aware.
class HiveTransactionHandle implements TransactionHandle {
  const HiveTransactionHandle();
}
