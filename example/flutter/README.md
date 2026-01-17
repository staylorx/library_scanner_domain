# Flutter Example for Library Scanner Domain

This example demonstrates how to configure and use the `library_scanner_domain` package in a Flutter application using Riverpod for dependency injection.

## Overview

The example shows how to:

1. Set up Riverpod providers for all domain layer dependencies
2. Configure Dio for HTTP requests
3. Implement ImageService using Flutter's image_picker
4. Use Sembast for persistent database storage
5. Create providers for repositories, services, and usecases
6. Consume the data in a Flutter UI

## Running the Example

1. Navigate to the `example/flutter` directory
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app

## Key Components

- **Riverpod**: Used for dependency injection and state management
- **Dio**: HTTP client for API calls
- **Sembast**: Embedded database stored in the app's documents directory
- **FlutterImageService**: Flutter-specific implementation using image_picker for gallery/camera access
- **Providers**: Organized providers for factories, repositories, services, and usecases

## Architecture

The providers are structured in layers:

1. **Infrastructure**: Dio, database path
2. **Factories**: LibraryFactory for creating domain instances
3. **Repositories**: Data access layer
4. **Services**: Business logic services
5. **Usecases**: Application logic
6. **UI State**: Providers that combine usecases for UI consumption

## Permissions

Make sure to add the necessary permissions to your `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` for camera and photo library access if using image picking features.

## Notes

This is a basic example showing the setup. In a real application, you would:

- Add proper error handling and loading states
- Implement more complex UI with lists, forms, etc.
- Add authentication if needed
- Configure proper logging
- Handle database migrations