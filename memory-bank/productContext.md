# Product Context

This file provides a high-level overview of the library_scanner_domain project.

# library_scanner_domain

[![pub package](https://img.shields.io/pub/v/library_scanner_domain.svg)](https://pub.dev/packages/library_scanner_domain)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The domain layer for the library scanner app, providing a comprehensive set of entities, repositories, and use cases for managing a personal library of books, authors, tags, and metadata.

## Architecture

The project follows Clean Architecture principles with three main layers:

- **Domain Layer**: Contains entities, repositories interfaces, services interfaces, and use cases. Pure business logic with no external dependencies.
- **Data Layer**: Contains repository implementations, data sources, and external service integrations. Handles data persistence and external APIs.
- **Presentation Layer**: Contains Riverpod providers for state management and dependency injection.

## Key Dependencies

- **fpdart**: Functional programming library for Either, TaskEither, and functional constructs.
- **riverpod**: State management and dependency injection (used only in presentation layer).
- **sembast**: NoSQL database for local storage.
- **dio**: HTTP client for API calls.
- **uuid**: UUID generation for unique identifiers.
- **equatable**: Value equality for entities.

## Development Rules

- Functional programming with fpdart throughout.
- No build_runner or code generation tools.
- No mockito; use mocktail for testing.
- No state management or DI frameworks in domain/data layers.
- Sync operations for pure business rules, async for external interactions.
- Never try-catch; use TaskEither.tryCatch for exceptions.
- Use match/fold for Either handling.
- Return Unit instead of void where appropriate.
- All files use LF line endings, no CRLF.
- Named parameters for public methods.

## Features

* **Book Management**: Add, update, delete, and query books with rich metadata including ISBN, title, authors, tags, and cover images.
* **Author Management**: Handle authors with sorting and filtering capabilities.
* **Tag System**: Organize books with customizable tags.
* **Metadata Fetching**: Integrate with external APIs to fetch book metadata by ISBN.
* **Library Operations**: Import/export library data, clear library, and detect duplicates.
* **Sorting and Filtering**: Flexible sorting options for books and authors.
* **Barcode Scanning**: Support for barcode scanning services.
* **Database Integration**: Uses Sembast for local storage with unit of work pattern.
* **ID Registry**: Separate registries for author and book IDs to prevent conflicts.
* **Validation Services**: Comprehensive validation for books and authors.
* **Comprehensive Testing**: Unit, integration, and benchmark tests with high coverage.
## Recent Changes

[2026-01-23 07:23:52] - Removed all metadata fetching functionality from the library_scanner_domain package to keep the domain focused on core book/author/tag management. This includes removing BookMetadata entity, BookMetadataRepository, FetchBookMetadataByIsbnUsecase, RefetchBookCoversUsecase, ScanAndAddBookUsecase, BookApiService, ImageService, and related implementations. The Book entity retains the coverImage property as optional, allowing downstream apps to handle image population. This change eliminates external API dependencies from the domain layer, adhering to Clean Architecture principles.
