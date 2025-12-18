# library_scanner_domain

[![pub package](https://img.shields.io/pub/v/library_scanner_domain.svg)](https://pub.dev/packages/library_scanner_domain)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The domain layer for the library scanner app, providing a comprehensive set of entities, repositories, and use cases for managing a personal library of books, authors, tags, and metadata.

## Features

- **Book Management**: Add, update, delete, and query books with rich metadata including ISBN, title, authors, tags, and cover images.
- **Author Management**: Handle authors with sorting and filtering capabilities.
- **Tag System**: Organize books with customizable tags.
- **Metadata Fetching**: Integrate with external APIs to fetch book metadata by ISBN.
- **Library Operations**: Import/export library data, clear library, and detect duplicates.
- **Sorting and Filtering**: Flexible sorting options for books and authors.
- **Barcode Scanning**: Support for barcode scanning services.
- **Database Integration**: Uses Sembast for local storage.
- **Settings Management**: Persistent settings using shared preferences.

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

### Basic Setup

Import the package:

```dart
import 'package:library_scanner_domain/library_scanner_domain.dart';
```

Initialize repositories and services (example using Riverpod):

```dart
final bookRepository = BookRepositoryImpl(databaseService: sembastDatabase);
final authorRepository = AuthorRepositoryImpl(databaseService: sembastDatabase);
// ... initialize other repositories
```

### Adding a Book

```dart
final addBookUseCase = AddBookUseCase(bookRepository: bookRepository);
final book = Book(
  id: BookId('unique-id'),
  title: 'Sample Book',
  authors: [Author(name: 'Author Name')],
  isbn: '978-1234567890',
  // ... other fields
);
await addBookUseCase(book);
```

### Fetching Book Metadata

```dart
final fetchMetadataUseCase = FetchBookMetadataByIsbnUseCase(bookApiService: bookApiService);
final metadata = await fetchMetadataUseCase('978-1234567890');
```

### Querying Books

```dart
final getBooksUseCase = GetBooksUseCase(bookRepository: bookRepository);
final books = await getBooksUseCase();
```

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
