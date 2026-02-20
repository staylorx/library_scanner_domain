# library_scanner_domain

[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](LICENSE)

The domain layer for the library scanner app — a clean-architecture Melos monorepo providing entities, repositories, and use cases for managing books, authors, and tags.

## Package structure

| Package | Role |
|---|---|
| `library_scanner_core` | Domain facade (`LibraryDomain`) — the only package most consumers import |
| `datastore_sembast` | Sembast backend + `SembastDomainFactory` |
| `datastore_hive` | Hive backend + `HiveDomainFactory` |
| `datastore_isar` | Isar backend + `IsarDomainFactory` (full ACID transactions) |
| `domain_entities` | Pure entity classes |
| `domain_contracts` | Repository + service interfaces |
| `domain_usecases` | Use-case implementations |
| `dataservice_filtering` | Author/book filtering + sorting services |
| `datastore_files` | YAML file import/export services |

## Installation

A consumer depends on **`library_scanner_core`** plus **exactly one** backend package.
No other datastore packages are pulled in.

```yaml
# pubspec.yaml (Flutter / Dart consumer)
dependencies:
  library_scanner_core: any

  # Pick ONE backend:
  datastore_sembast: any       # lightweight, pure-Dart — good default
  # datastore_hive: any        # fast binary store
  # datastore_isar: any        # full ACID write transactions
```

See [`packages/example/pubspec.yaml`](packages/example/pubspec.yaml) for an annotated example.

## Usage

### Sembast (lightweight default)

```dart
import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:library_scanner_core/library_scanner_domain.dart';

final unitOfWork = SembastUnitOfWork(
  sembastDb: SembastDatabase(testDbPath: 'path/to/library.db'),
);

final LibraryDomain domain = SembastDomainFactory.create(
  unitOfWork: unitOfWork,
);
```

### Hive

```dart
import 'package:datastore_hive/datastore_hive.dart';
import 'package:library_scanner_core/library_scanner_domain.dart';

final hiveDb = HiveDatabase();
final unitOfWork = HiveUnitOfWork();

final LibraryDomain domain = HiveDomainFactory.createWithDatabase(
  hiveDb: hiveDb,
  unitOfWork: unitOfWork,
);
```

### Isar (ACID transactions)

```dart
import 'package:datastore_isar/datastore_isar.dart';
import 'package:library_scanner_core/library_scanner_domain.dart';

final isarDb = IsarDatabase();
final unitOfWork = IsarUnitOfWork(isarDb: isarDb);

final LibraryDomain domain = IsarDomainFactory.createWithDatabase(
  isarDb: isarDb,
  unitOfWork: unitOfWork,
);
```

### Working with the domain facade

All three backends return the same `LibraryDomain` facade — swap backends by changing one line:

```dart
// Add a book
final result = await domain.addBookUsecase(book: myBook).run();

// Query
final books = await domain.getBooksUsecase().run();

// Filter
final filtered = await domain.filterBooksUsecase(
  books: allBooks,
  query: 'fantasy',
).run();

// Export to YAML
await domain.exportLibraryUsecase(filePath: 'library.yaml').run();

// Import from YAML
await domain.importLibraryUsecase(filePath: 'library.yaml').run();
```

All use-cases return `TaskEither<Failure, T>` from [fpdart](https://pub.dev/packages/fpdart).

## Architecture

The dependency graph flows strictly inward — `core` never imports any datastore package:

```
datastore_sembast ──┐
datastore_hive    ──┼──► library_scanner_core ──► domain_usecases
datastore_isar    ──┘                          ──► domain_contracts
                                               ──► domain_entities
```

Each `*DomainFactory` lives in its own backend package and wires together:

1. **ID registry services** — deterministic ID generation
2. **Datasources** — backend-specific read/write primitives
3. **Repositories** — domain-contract implementations
4. **Services** — filtering, sorting, validation
5. **Use cases** — all business logic
6. **`LibraryDomain`** — the returned facade

## Adding a new backend

1. Create `packages/datastore_mydb/`
2. Implement datasources, unit of work, and repositories against `domain_contracts`
3. Add a `MyDbDomainFactory` that wires everything and returns `LibraryDomain`
4. Export the factory from `lib/datastore_mydb.dart`
5. No changes to `library_scanner_core` or any other package

## Running tests

```bash
dart test packages/datastore_sembast/test
dart test packages/datastore_isar/test
```

Or via Melos:

```bash
melos run test:all
```

## License

Apache 2 — see [LICENSE](LICENSE).
