/// Represents a unit of work in the domain, encapsulating a set of operations that should be treated as a single transaction.
/// The generic type [T] represents the infrastructure-specific transaction handle (defaults to Object?).
/// Domain code uses UnitOfWork without caring about the handle; infrastructure can attach a handle when needed.
class UnitOfWork<T extends Object?> {
  /// The infrastructure-specific transaction handle, if any.
  final T? transactionHandle;

  /// Creates a UnitOfWork with an optional transaction handle.
  /// Use [UnitOfWork.withoutHandle] for domain-level operations that don't need a handle.
  const UnitOfWork([this.transactionHandle]);

  /// Creates a UnitOfWork without a transaction handle.
  /// Suitable for domain code that doesn't need infrastructure details.
  const UnitOfWork.withoutHandle() : transactionHandle = null;

  /// Returns the transaction handle cast to [R], or null if the handle is not of type [R].
  R? maybeHandle<R extends Object?>() {
    final handle = transactionHandle;
    return handle is R ? handle : null;
  }

  /// Returns true if this UnitOfWork has a transaction handle of type [R].
  bool hasHandle<R extends Object?>() => transactionHandle is R;
}
