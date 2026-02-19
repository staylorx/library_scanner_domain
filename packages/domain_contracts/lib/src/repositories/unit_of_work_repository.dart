import 'unit_of_work.dart';

/// Abstraction for a unit of work (transaction) in the persistence layer.
///
/// Manages a transactional boundary for a set of operations.
/// Implementations should ensure transactional semantics (ACID properties).
///
/// The [currentUnitOfWork] provides access to the active transaction context,
/// which may carry an infrastructure-specific handle (see [UnitOfWork]).
abstract class UnitOfWorkRepository {
  /// Returns the currently active unit of work.
  /// If no transaction is active, this may return a UnitOfWork without a handle.
  UnitOfWork get currentUnitOfWork;

  /// Commits all changes made within the current unit of work.
  /// After successful commit, the transaction is considered complete.
  /// Implementations may close the underlying transaction handle.
  Future<void> saveChanges();

  /// Discards all changes made within the current unit of work.
  /// The transaction is rolled back and any changes are lost.
  /// Implementations may close the underlying transaction handle.
  Future<void> discardChanges();
}
