# Flutter Example for Library Scanner Domain

This example demonstrates how to configure and use the `library_scanner_domain` package in a Flutter application using Riverpod for dependency injection.

## Overview

The example shows how to:

1. Override the library's external providers with Flutter-specific implementations
2. Set up persistent database storage using Sembast
3. Configure HTTP client and image services for Flutter
4. Use provider overrides in `ProviderScope` for the entire app
5. Access repositories, services, and usecases through Riverpod providers
6. Consume data in Flutter UI components

## Running the Example

1. Navigate to the `example/flutter` directory
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app

## Key Components

- **Riverpod ProviderScope**: Global provider container with overrides
- **Provider Overrides**: Override external providers with Flutter implementations
- **Dio**: HTTP client for API calls
- **Sembast**: Embedded database stored in the app's documents directory
- **FlutterImageService**: Flutter-specific implementation using image_picker for gallery/camera access
- **FutureProvider**: For data fetching and UI state management

## Provider Setup

The library requires overriding four external providers in your `ProviderScope`:

```dart
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

See `lib/providers.dart` for the complete override implementations.

## Architecture

The providers are structured in layers:

1. **External Overrides**: Override library's external providers with Flutter implementations
2. **Infrastructure**: Dio, database path, image service
3. **Domain Providers**: Automatic wiring of repositories, services, and usecases
4. **UI State**: FutureProvider instances that consume usecases for UI consumption

## Permissions

Make sure to add the necessary permissions to your `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` for camera and photo library access if using image picking features.

## Notes

This is a basic example showing the setup. In a real application, you would:

- Add proper error handling and loading states
- Implement more complex UI with lists, forms, etc.
- Add authentication if needed
- Configure proper logging
- Handle database migrations