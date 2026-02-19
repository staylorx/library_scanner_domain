/// Marker interface for infrastructure-specific transaction handles.
/// Domain code can reference TransactionHandle without knowing concrete implementations.
abstract class TransactionHandle {
  const TransactionHandle();
}