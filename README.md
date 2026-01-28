# library_scanner_domain

[![pub package](https://img.shields.io/pub/v/library_scanner_domain.svg)](https://pub.dev/packages/library_scanner_domain)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The domain layer for the library scanner app, providing a comprehensive set of entities, repositories, and use cases for managing a personal library of books, authors, and tags.

## Features

- **Book Management**: Add, update, delete, and query books with rich metadata including ISBN, title, authors, tags, and cover images.
- **Author Management**: Handle authors with sorting and filtering capabilities.
- **Tag System**: Organize books with customizable tags.
- **Library Operations**: Import/export library data, clear library, and detect duplicates.
- **Sorting and Filtering**: Flexible sorting options for books and authors.
- **Database Integration**: Database-agnostic design with Sembast implementation provided.

## Installation

Add `library_scanner_domain` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  library_scanner_domain:
    path: ../path/to/library_scanner_domain # Since publish_to is none, use path dependency
```

Then run:

```bash
flutter pub get
```

## Usage

The library scanner domain is used through the factory pattern for dependency injection.

### Using the Library Domain Factory and Facade

The library provides a factory pattern for creating a fully wired domain layer instance, along with a facade class for easy access to all business logic operations.

#### Creating a Library Domain Instance

Use `LibraryDomainFactory.create()` to instantiate the domain layer with your database implementations:

```dart
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Provide your database service and unit of work implementations
final myDatabaseService = MyDatabaseService();
final myUnitOfWork = MyUnitOfWork();

// Create the domain instance
final libraryDomain = LibraryDomainFactory.create(
  databaseService: myDatabaseService,
  unitOfWork: myUnitOfWork,
  // Optional: provide custom file loaders/writers
  fileLoader: MyFileLoader(),
  fileWriter: MyFileWriter(),
);
```

#### Using the Facade

The `LibraryDomain` facade provides access to all usecases for managing your library:

```dart
// Add a book
final addBookResult = await libraryDomain.addBookUsecase(book: myBook);

// Get all books
final booksResult = await libraryDomain.getBooksUsecase();

// Filter books
final filteredBooks = await libraryDomain.filterBooksUsecase(
  books: allBooks,
  query: 'fantasy',
);

// Export library
final exportResult = await libraryDomain.exportLibraryUsecase(filePath: 'library.yaml');
```

#### Example with Sembast

```dart
import 'package:sembast/sembast.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

final dbService = SembastDatabase(testDbPath: 'path/to/db');
final unitOfWork = SembastUnitOfWork(dbService: dbService);

final libraryDomain = LibraryDomainFactory.create(
  databaseService: dbService,
  unitOfWork: unitOfWork,
);

final books = await libraryDomain.getBooksUsecase();
```

This approach is framework-agnostic and suitable for CLI apps, testing, or when you prefer manual dependency injection.

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

## Factory Setup and Dependency Injection

The library provides a factory pattern for dependency injection. Use `LibraryDomainFactory` to create a fully wired domain instance.



### Factory Examples

#### Flutter App (using Factory)

```dart
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbPath = '${directory.path}/library.db';
  final dbService = SembastDatabase(testDbPath: dbPath);
  final unitOfWork = SembastUnitOfWork(dbService: dbService);

  final libraryDomain = LibraryDomainFactory.create(
    databaseService: dbService,
    unitOfWork: unitOfWork,
  );

  runApp(MyApp(libraryDomain: libraryDomain));
}
```

#### CLI App (using Factory)

```dart
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() async {
  final dbService = SembastDatabase(testDbPath: null); // In-memory
  final unitOfWork = SembastUnitOfWork(dbService: dbService);

  final libraryDomain = LibraryDomainFactory.create(
    databaseService: dbService,
    unitOfWork: unitOfWork,
  );

  // Use the domain
  final books = await libraryDomain.getBooksUsecase();
}
```

### Usage Patterns

#### Recommended: Use Usecases (Business Logic Layer)

```dart
final libraryDomain = LibraryDomainFactory.create(...);

final books = await libraryDomain.getBooksUsecase();
```

#### Alternative: Direct Repository Access

```dart
final dataAccess = ref.watch(dataAccessProvider);
// Access repositories directly
final books = await dataAccess.bookRepository.getAll();
final authors = await dataAccess.authorRepository.getAll();
```

### Complete Examples

See the factory examples above for full implementations.

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
