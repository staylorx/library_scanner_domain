# library\_scanner\_domain

[![pub package](https://img.shields.io/pub/v/library_scanner_domain.svg)](https://pub.dev/packages/library_scanner_domain)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The domain layer for the library scanner app, providing a comprehensive set of entities, repositories, and use cases for managing a personal library of books, authors, and tags.

## Features

* **Book Management**: Add, update, delete, and query books with rich metadata including ISBN, title, authors, tags, and cover images.
* **Author Management**: Handle authors with sorting and filtering capabilities.
* **Tag System**: Organize books with customizable tags.
* **Library Operations**: Import/export library data, clear library, and detect duplicates.
* **Sorting and Filtering**: Flexible sorting options for books and authors.
* **Barcode Scanning**: Support for barcode scanning services.
* **Database Integration**: Database-agnostic design with Sembast implementation provided.

## Installation

Add `library_scanner_domain` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  library_scanner_domain:
    path: ../path/to/library_scanner_domain  # Since publish_to is none, use path dependency
```

Then run:

```bash
flutter pub get
```

## Usage

See the test files for detailed usage examples and how the code works.

## Implementing Custom Database Layer

This library is designed with clean architecture principles, making the domain layer database-agnostic. The repository implementations in the data layer are generic and work with any database through the `DatabaseService` and `UnitOfWork` interfaces defined in the domain.

### Database Agnostic Design

The `BookRepositoryImpl`, `AuthorRepositoryImpl`, and `TagRepositoryImpl` are already database-agnostic. They use datasources that depend on the `DatabaseService` interface, allowing you to plug in any database implementation without modifying the repository code.

### Implementing Your Own Database

To integrate with a different database (e.g., SQLite, Firebase, etc.):

1. **Implement `DatabaseService`**:
   - Create a class that implements the `DatabaseService` interface.
   - Handle database connections, queries, and operations.

2. **Implement `UnitOfWork`**:
   - Create a class that implements the `UnitOfWork` interface.
   - Manage transactions and ensure data consistency.

3. **Create Datasources (if needed)**:
   - The library provides `AuthorDatasource`, `BookDatasource`, and `TagDatasource` for Sembast.
   - If your database requires different datasources, implement them using your `DatabaseService`.

4. **Override External Providers**:
   - Instantiate `LibraryFactory` with your custom `DatabaseService` and `UnitOfWork`.
   - The factory will create all repositories and services using your implementations.

Example:

```dart
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Your custom implementations
class MyDatabaseService implements DatabaseService {
  // Implement all required methods
}

class MyUnitOfWork implements UnitOfWork {
  // Implement all required methods
}

// Create factory
final myDbService = MyDatabaseService();
final myUnitOfWork = MyUnitOfWork();
final factory = LibraryFactory(
  dbService: myDbService,
  unitOfWork: myUnitOfWork,
  apiService: myApiService,  // BookApiService instance
  imageService: myImageService,  // ImageService instance
);

// Now use factory to create repositories
final bookRepo = await factory.createBookRepository();
```

### Customizing Datasources

If you need to customize the datasources (e.g., `BookDatasource`, `AuthorDatasource`, `TagDatasource`) for specific database optimizations or additional logic, you can subclass `LibraryFactory` and override the datasource creation methods.

The `LibraryFactory` provides separate methods for creating each datasource, making customization straightforward:

1. Create custom datasource classes that implement the same methods as the originals (or extend them).
2. Subclass `LibraryFactory` and override the specific `create*Datasource()` methods to return your custom implementations.
3. The repository creation methods will automatically use your custom datasources.

Example:

```dart
class MyCustomBookDatasource extends BookDatasource {
  // Add custom logic or optimizations
  MyCustomBookDatasource({required DatabaseService dbService})
      : super(dbService: dbService);

  // Override methods as needed
  @override
  Future<Either<Failure, List<BookModel>>> getAllBooks() async {
    // Custom implementation
  }
}

class MyCustomLibraryFactory extends LibraryFactory {
  MyCustomLibraryFactory({
    required DatabaseService dbService,
    required UnitOfWork unitOfWork,
    required BookApiService apiService,
    required ImageService imageService,
  }) : super(
          dbService: dbService,
          unitOfWork: unitOfWork,
          apiService: apiService,
          imageService: imageService,
        );

  @override
  BookDatasource createBookDatasource() => MyCustomBookDatasource(dbService: _dbService);
}
```

This approach is much simpler than overriding entire repository creation methods, as you only need to customize the specific datasource(s) you care about.

### Provided Implementations

The library includes Sembast implementations:
- `SembastDatabase` implements `DatabaseService`
- `SembastUnitOfWork` implements `UnitOfWork`

To use Sembast, instantiate `LibraryFactory` with `SembastDatabase` and `SembastUnitOfWork`:

```dart
final dbService = SembastDatabase(testDbPath: dbPath); // dbPath can be null for in-memory
final unitOfWork = SembastUnitOfWork(dbService: dbService);
final factory = LibraryFactory(
  dbService: dbService,
  unitOfWork: unitOfWork,
  apiService: apiService,
  imageService: imageService,
);
```

## Provider Setup and Dependency Injection

The library uses Riverpod for dependency injection. All providers are defined in `lib/providers.dart`. The library provides external dependency providers that **must be overridden** by consumers, and internal providers that wire up the domain layer automatically.

### External Dependencies (Must Override)

These providers throw `UnimplementedError` and must be overridden with your implementations:

- `dioProvider`: HTTP client for API calls (provide `Dio` instance)
- `databaseServiceProvider`: Database service implementation (provide `DatabaseService` instance)
- `transactionProvider`: Transaction management (Unit of Work pattern, provide `UnitOfWork` instance)
- `imageServiceProvider`: Image processing service (provide `ImageService` instance)

### Internal Providers (Automatic)

These providers are wired automatically once external dependencies are provided:

- **Data Access**: `dataAccessProvider` - Main entry point providing `LibraryDataAccess` with all repositories and services
- **Repositories**: `bookRepositoryProvider`, `authorRepositoryProvider`, `tagRepositoryProvider`, `bookMetadataRepositoryProvider`
- **Services**: Filtering, sorting, validation, and ID registry services
- **Usecases**: All business logic operations (add, update, delete, query operations)

### Provider Override Examples

#### Flutter App (using overrideWith)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path_provider/path_provider.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final databasePathProvider = FutureProvider<String?>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/library.db';
});

// Override external providers
final databaseServiceProviderOverride = databaseServiceProvider.overrideWith(
  (ref) async {
    final dbPath = await ref.watch(databasePathProvider.future);
    return SembastDatabase(testDbPath: dbPath);
  },
);

final transactionProviderOverride = transactionProvider.overrideWith((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SembastUnitOfWork(dbService: dbService);
});

final imageServiceProviderOverride = imageServiceProvider.overrideWith((ref) {
  final dio = ref.watch(dioProvider);
  return FlutterImageService(dio); // Your ImageService implementation
});

// Use in ProviderScope
void main() {
  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProviderOverride,
        transactionProviderOverride,
        imageServiceProviderOverride,
      ],
      child: MyApp(),
    ),
  );
}
```

#### CLI App (using ProviderContainer)

```dart
import 'package:riverpod/riverpod.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() async {
  final dio = Dio();
  final dbService = SembastDatabase(testDbPath: null); // In-memory
  final unitOfWork = SembastUnitOfWork(dbService: dbService);
  final imageService = CliImageService(dio); // Your ImageService implementation

  final container = ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      databaseServiceProvider.overrideWithValue(dbService),
      transactionProvider.overrideWithValue(unitOfWork),
      imageServiceProvider.overrideWithValue(imageService),
    ],
  );

  // Now use the container to access providers
  final dataAccess = await container.read(dataAccessProvider.future);
  final getBooksUsecase = await container.read(getBooksUsecaseProvider.future);
}
```

### Usage Patterns

#### Recommended: Use Usecases (Business Logic Layer)

```dart
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final usecase = await ref.watch(getBooksUsecaseProvider.future);
  final result = await usecase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (books) => books,
  );
});
```

#### Alternative: Direct Repository Access

```dart
final dataAccess = ref.watch(dataAccessProvider);
// Access repositories directly
final books = await dataAccess.bookRepository.getAll();
final authors = await dataAccess.authorRepository.getAll();
```

### Complete Examples

See the example applications for full implementations:
- **Flutter**: `example/flutter/lib/providers.dart` and `example/flutter/lib/main.dart`
- **CLI**: `example/cli/lib/main.dart`

This approach ensures that repositories are created once and reused, while allowing easy testing and dependency swapping.

## API Reference

For detailed API documentation, see the [generated docs](https://pub.dev/documentation/library_scanner_domain/latest/).

To generate docs locally:

```bash
dart doc .
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Add tests if applicable.
5. Submit a pull request.

## License

This project is licensed under the Apache 2 License - see the [LICENSE](LICENSE) file for details.
