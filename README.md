# library\_scanner\_domain

[![pub package](https://img.shields.io/pub/v/library_scanner_domain.svg)](https://pub.dev/packages/library_scanner_domain)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The domain layer for the library scanner app, providing a comprehensive set of entities, repositories, and use cases for managing a personal library of books, authors, tags, and metadata.

## Features

* **Book Management**: Add, update, delete, and query books with rich metadata including ISBN, title, authors, tags, and cover images.
* **Author Management**: Handle authors with sorting and filtering capabilities.
* **Tag System**: Organize books with customizable tags.
* **Metadata Fetching**: Integrate with external APIs to fetch book metadata by ISBN.
* **Library Operations**: Import/export library data, clear library, and detect duplicates.
* **Sorting and Filtering**: Flexible sorting options for books and authors.
* **Barcode Scanning**: Support for barcode scanning services.
* **Database Integration**: Uses Sembast for local storage.
* **Settings Management**: Persistent settings using shared preferences.

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
