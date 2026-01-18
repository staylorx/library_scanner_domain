# CLI Example for Library Scanner Domain

This example demonstrates how to configure and use the `library_scanner_domain` package in a CLI (Command Line Interface) application using Riverpod for dependency injection.

## Overview

The example shows how to:

1. Set up Riverpod `ProviderContainer` with provider overrides
2. Configure external dependencies (Dio, database, image service)
3. Override the library's external providers with your implementations
4. Access repositories, services, and usecases through the provider container
5. Use usecases to interact with the domain layer

## Running the Example

1. Navigate to the `example/cli` directory
2. Run `dart pub get` to install dependencies
3. Run `dart run lib/main.dart` to execute the example

## Key Components

- **Riverpod ProviderContainer**: Manages dependency injection and provider overrides
- **Dio**: HTTP client for API requests to external services
- **Sembast**: Embedded database for data persistence (in-memory for this example)
- **CliImageService**: CLI-specific implementation of ImageService for image operations
- **Provider Overrides**: Override external providers with concrete implementations

## Provider Setup

The library requires overriding four external providers:

```dart
final container = ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(Dio()),
    databaseServiceProvider.overrideWithValue(SembastDatabase(testDbPath: null)),
    transactionProvider.overrideWithValue(SembastUnitOfWork(dbService: dbService)),
    imageServiceProvider.overrideWithValue(CliImageService(dio)),
  ],
);
```

## Configuration

The example uses an in-memory Sembast database for simplicity. To use a persistent database, pass a file path to `SembastDatabase(testDbPath: path)`.

For production use, you would implement proper error handling, logging, and possibly use a DI container like `get_it`.