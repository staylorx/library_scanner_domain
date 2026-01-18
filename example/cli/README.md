# CLI Example for Library Scanner Domain

This example demonstrates how to configure and use the `library_scanner_domain` package in a CLI (Command Line Interface) application.

## Overview

The example shows how to:

1. Set up the necessary dependencies (Dio for HTTP, etc.)
2. Create implementations for required services (ImageService)
3. Initialize the LibraryFactory with Sembast database
4. Create repositories and services
5. Use usecases to interact with the domain layer

## Running the Example

1. Navigate to the `example/cli` directory
2. Run `dart pub get` to install dependencies
3. Run `dart run lib/main.dart` to execute the example

## Key Components

- **Dio**: Used for HTTP requests to external APIs
- **Sembast**: Embedded database for data persistence
- **CliImageService**: A CLI-specific implementation of ImageService that handles image operations (downloads only, since CLI can't pick from gallery/camera)
- **LibraryFactory**: Central factory for creating all domain layer instances

## Configuration

The example uses an in-memory Sembast database for simplicity. To use a persistent database, pass a file path to `SembastDatabase(testDbPath: path)`.

For production use, you would implement proper error handling, logging, and possibly use a DI container like `get_it`.