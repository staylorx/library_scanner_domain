# Examples for Library Scanner Domain

This directory contains examples showing how to configure and use the `library_scanner_domain` package in different types of applications.

## Available Examples

### CLI Example (`cli/`)

A command-line application demonstrating manual dependency injection and configuration of the domain layer.

- **Location**: `example/cli/`
- **Technology**: Dart console app
- **DI**: Manual instantiation
- **Database**: In-memory Sembast
- **Image Service**: CLI implementation (downloads only)

### Flutter Example (`flutter/`)

A Flutter mobile application demonstrating Riverpod-based dependency injection.

- **Location**: `example/flutter/`
- **Technology**: Flutter with Riverpod
- **DI**: Riverpod providers
- **Database**: Persistent Sembast in app documents
- **Image Service**: Flutter implementation with image_picker

## Common Setup Steps

Both examples follow these general steps:

1. **HTTP Client**: Configure Dio for API calls
2. **Image Service**: Implement or configure ImageService
3. **Database**: Set up Sembast database
4. **Factory**: Create LibraryFactory with dependencies
5. **Repositories**: Initialize data repositories
6. **Services**: Set up domain services
7. **Usecases**: Create application usecases

## Running the Examples

### CLI
```bash
cd example/cli
dart pub get
dart run lib/main.dart
```

### Flutter
```bash
cd example/flutter
flutter pub get
flutter run
```

## Key Differences

- **CLI**: Uses manual DI, simpler setup, no UI concerns
- **Flutter**: Uses Riverpod for DI, persistent storage, full UI integration

Both examples demonstrate the same core domain layer usage patterns, adapted for their respective platforms.