# UnitOfWork Guide

## Introduction

The **UnitOfWork** pattern is a fundamental concept in Domain-Driven Design (DDD) that represents a transactional boundary for a set of operations. In the Electrical Junctions Domain package, `UnitOfWork` serves as a bridge between the domain layer (business logic) and the infrastructure layer (data persistence). This guide explains:

1. **Conceptual model**: What UnitOfWork represents and why it's needed.
2. **Technical implementation**: How `UnitOfWork` wraps infrastructure-specific transaction handles.
3. **Understanding transaction handles**: How UnitOfWork encapsulates transaction handles (not to be confused with entity handles used elsewhere in the package).
4. **Implementing new data sources**: Step-by-step guidance for adding support for new persistence technologies (e.g., Hive, SQLite, REST APIs).
5. **Usage examples**: How to work with `UnitOfWork` in repository contracts and use cases.

## What is a UnitOfWork?

A UnitOfWork tracks all changes to entities during a business transaction. When the transaction completes, the UnitOfWork ensures all changes are persisted atomically (commit) or discarded (rollback). In traditional database terms, this corresponds to a **database transaction**.

In our architecture:

- **Domain layer** thinks in terms of `UnitOfWork` as an abstract transactional boundary.
- **Infrastructure layer** attaches a concrete transaction handle (e.g., a Sembast `Transaction`, a SQL `Connection`, a Hive `Box` transaction) to the `UnitOfWork`.
- **Application layer** coordinates the UnitOfWork across multiple repository operations.

## The UnitOfWork Value Object

Located at `packages/domain_entities/lib/src/value_objects/unit_of_work.dart`, the `UnitOfWork<T>` class is generic over the transaction handle type `T` (defaults to `Object?`).

```dart
/// Domain code uses UnitOfWork without caring about the handle; 
/// infrastructure can attach a handle when needed.
class UnitOfWork<T extends Object?> {
  final T? transactionHandle;

  const UnitOfWork([this.transactionHandle]);

  const UnitOfWork.withoutHandle() : transactionHandle = null;

  R? maybeHandle<R extends Object?>() { ... }

  bool hasHandle<R extends Object?>() => transactionHandle is R;
}
```

Key points:

- `UnitOfWork.withoutHandle()` creates a handle‑less instance for domain‑level operations that don’t need a concrete transaction.
- The generic type `T` is the infrastructure‑specific handle type (e.g., `sembast.Transaction`, `sqlite.Database`).
- `maybeHandle<R>()` safely casts the internal handle to type `R`; returns `null` if the handle is not of that type.
- `hasHandle<R>()` checks whether the internal handle is of type `R`.

## Transaction Handles (Not Entity Handles)

The **transaction handle** inside a `UnitOfWork` is **not** the same as the entity handles (`DeviceHandle`, `CircuitHandle`, etc.) used elsewhere in the package:

- **Transaction handles** are infrastructure‑specific objects (e.g., a Sembast `Transaction`, a SQLite `Database`, a Hive `Box`) that represent an ongoing transaction. They are carried inside a `UnitOfWork` and are never exposed to the domain layer.
- **Entity handles** are domain value objects that identify specific entities (e.g., `DeviceHandle('panel_1')`). They appear as the `THandle` parameter in `BasicCrudContract<T, THandle>` and are used in repository method parameters like `getByHandle`.

The `UnitOfWork` pattern wraps the technical transaction handle, allowing the domain layer to remain agnostic of infrastructure details while still supporting transactional operations.

## UnitOfWorkRepository

The `UnitOfWorkRepository` abstract class (`packages/domain_contracts/lib/src/repositories/unit_of_work_repository.dart`) provides the infrastructure’s view of an active transaction:

```dart
abstract class UnitOfWorkRepository {
  UnitOfWork get currentUnitOfWork;
  Future<void> saveChanges();
  Future<void> discardChanges();
}
```

- `currentUnitOfWork` returns the currently active `UnitOfWork` (which may or may not have a transaction handle attached).
- `saveChanges()` commits the transaction (e.g., calls `transaction.commit()`).
- `discardChanges()` rolls back the transaction (e.g., calls `transaction.rollback()`).

Implementations of `UnitOfWorkRepository` are responsible for:

1. Creating a transaction handle when a UnitOfWork starts.
2. Attaching that handle to a `UnitOfWork` instance.
3. Providing that instance via `currentUnitOfWork`.
4. Committing or rolling back the underlying transaction when `saveChanges()` or `discardChanges()` is called.

## How UnitOfWork Flows Through the Layers

1. **Infrastructure layer** creates a concrete transaction handle (e.g., a Sembast transaction) and wraps it in a `UnitOfWork`.
2. The `UnitOfWork` is passed to repository methods via the optional `unitOfWork` parameter in `BasicCrudContract`.
3. Repository implementations use the attached handle to perform transactional operations.
4. The application layer (use cases) calls `saveChanges()` or `discardChanges()` on the `UnitOfWorkRepository` to finalize the transaction.

When no `unitOfWork` is provided, repository implementations may operate outside a transaction (auto‑commit) or use a default transaction strategy, depending on the persistence technology.

## Implementing a New Data Source

To add support for a new persistence technology (e.g., **Hive**), follow these steps:

### 1. Define the Transaction Handle Type

Identify the object that represents a transaction in your chosen technology. For Hive, this might be a `Box` (since Hive transactions are per‑box) or a custom transaction object if you use Hive’s transaction support.

Example:
```dart
import 'package:hive/hive.dart';

typedef HiveTransactionHandle = Box;
```

### 2. Implement UnitOfWorkRepository

Create a concrete class that implements `UnitOfWorkRepository`. It must manage the lifecycle of Hive transactions and provide a `UnitOfWork<HiveTransactionHandle>`.

```dart
import 'package:electrical_junctions_contracts/electrical_junctions_contracts.dart';
import 'package:hive/hive.dart';

class HiveUnitOfWorkRepository implements UnitOfWorkRepository {
  final Box _box;
  Transaction? _currentTransaction;

  HiveUnitOfWorkRepository(this._box);

  @override
  UnitOfWork<Box> get currentUnitOfWork {
    if (_currentTransaction == null) {
      // Start a new Hive transaction (pseudo‑code; adapt to Hive’s actual API)
      _currentTransaction = _box.transaction;
    }
    return UnitOfWork<Box>(_box);
  }

  @override
  Future<void> saveChanges() async {
    if (_currentTransaction != null) {
      await _currentTransaction!.commit();
      _currentTransaction = null;
    }
  }

  @override
  Future<void> discardChanges() async {
    if (_currentTransaction != null) {
      await _currentTransaction!.rollback();
      _currentTransaction = null;
    }
  }
}
```

*Note:* Hive’s exact transaction API may differ; adjust accordingly.

### 3. Implement Repository Contracts

Each repository (`DeviceRepository`, `CircuitRepository`, etc.) must have a Hive‑specific implementation that accepts a `UnitOfWork<Box>` (or your handle type) and uses the attached handle for CRUD operations.

Example skeleton for `HiveDeviceRepository`:

```dart
class HiveDeviceRepository implements DeviceRepository {
  final Box _box;

  HiveDeviceRepository(this._box);

  @override
  TaskEither<Failure, Device> create({
    required Device item,
    UnitOfWork? unitOfWork,
  }) {
    return TaskEither<Failure, Device>.tryCatch(
      () async {
        // Use the transaction handle if provided
        final box = unitOfWork?.maybeHandle<Box>() ?? _box;
        // Convert Device to Hive‑compatible format and store
        // ...
        return item;
      },
      (error, stackTrace) => Failure.databaseError(error.toString()),
    );
  }

  // Implement other CRUD methods similarly...
}
```

### 4. Integrate with the Application Layer

Wire up your Hive repositories and `HiveUnitOfWorkRepository` in the application’s composition root (e.g., the `ElectricalJunctionsFacade`). The facade will pass the appropriate `UnitOfWork` to use cases when transactional consistency is required.

## Example: Using UnitOfWork in a Use Case

Consider a use case that creates a device and a circuit within a single transaction:

```dart
class CreateDeviceAndCircuitUseCase {
  final DeviceRepository _deviceRepo;
  final CircuitRepository _circuitRepo;
  final UnitOfWorkRepository _uowRepo;

  CreateDeviceAndCircuitUseCase(
    this._deviceRepo,
    this._circuitRepo,
    this._uowRepo,
  );

  Future<Either<Failure, Unit>> execute(Device device, Circuit circuit) async {
    // Obtain the current UnitOfWork (which carries a transaction handle)
    final uow = _uowRepo.currentUnitOfWork;

    // Perform both operations within the same transaction
    final deviceResult = await _deviceRepo.create(item: device, unitOfWork: uow).run();
    final circuitResult = await _circuitRepo.create(item: circuit, unitOfWork: uow).run();

    return deviceResult.fold(
      (failure) => Left(failure),
      (_) => circuitResult.fold(
        (failure) => Left(failure),
        (_) async {
          // Commit the transaction
          await _uowRepo.saveChanges();
          return const Right(unit);
        },
      ),
    );
  }
}
```

If any operation fails, the transaction can be rolled back by calling `_uowRepo.discardChanges()`.

## Best Practices

1. **Keep domain code handle‑agnostic**: Domain entities and use cases should never depend on a concrete transaction handle. Use `UnitOfWork.withoutHandle()` when a handle is not needed.

2. **Implement atomic operations**: Use `UnitOfWork` to group repository calls that must succeed or fail together.

3. **Handle transaction lifecycle carefully**: Ensure every started transaction is either committed or rolled back. Avoid leaking transaction handles.

4. **Test with in‑memory implementations**: Create an in‑memory `UnitOfWorkRepository` for testing that simulates transactional behavior without a real database.

5. **Document your handle types**: If you introduce a new transaction handle type, document its semantics and lifetime expectations.

## Common Pitfalls

- **Confusing entity handles with transaction handles**: Entity handles (like `DeviceHandle`) identify domain entities; transaction handles inside `UnitOfWork` identify infrastructure‑level transactions. Keep these concepts separate.
- **Forgetting to commit**: Always call `saveChanges()` after a successful transactional operation; otherwise changes may be lost.
- **Assuming a handle is always present**: Use `maybeHandle()` or `hasHandle()` to safely access the transaction handle; it may be `null` in domain‑level code.

## Conclusion

The `UnitOfWork` pattern decouples the domain layer from infrastructure‑specific transaction details. By using `UnitOfWork` to wrap transaction handles (not entity handles), you can add support for new data sources while maintaining clean architecture boundaries.

For further reading, see:

- [Domain-Driven Design](https://domainlanguage.com/ddd/) by Eric Evans
- [Unit of Work Pattern](https://martinfowler.com/eaaCatalog/unitOfWork.html) on Martin Fowler’s website
- The existing contract files (`unit_of_work_repository.dart`, `basic_crud_contract.dart`) in this repository.