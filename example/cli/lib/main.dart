// ignore_for_file: avoid_print, unused_local_variable

import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'image_service_impl.dart';

void main() async {
  // Initialize Dio for API calls
  final dio = Dio();

  // Create ImageService implementation for CLI
  final imageService = CliImageService(dio);

  // Create Sembast database and unit of work (in-memory for demo)
  final dbService = SembastDatabase(testDbPath: null);
  final unitOfWork = SembastUnitOfWork(dbService: dbService);

  // Create ProviderContainer with overrides
  final container = ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      databaseServiceProvider.overrideWithValue(dbService),
      unitOfWorkProvider.overrideWithValue(unitOfWork),
      imageServiceProvider.overrideWithValue(imageService),
    ],
  );

  // Read repositories
  final authorRepository = await container.read(
    authorRepositoryProvider.future,
  );
  final bookRepository = await container.read(bookRepositoryProvider.future);
  final tagRepository = await container.read(tagRepositoryProvider.future);
  final bookMetadataRepository = await container.read(
    bookMetadataRepositoryProvider.future,
  );

  // Read services
  final authorFilteringService = container.read(authorFilteringServiceProvider);
  final authorSortingService = container.read(authorSortingServiceProvider);
  final bookFilteringService = container.read(bookFilteringServiceProvider);
  final bookSortingService = container.read(bookSortingServiceProvider);
  final authorIdRegistryService = container.read(
    authorIdRegistryServiceProvider,
  );
  final bookIdRegistryService = container.read(bookIdRegistryServiceProvider);
  final authorValidationService = container.read(
    authorValidationServiceProvider,
  );
  final bookValidationService = container.read(bookValidationServiceProvider);

  // Read LibraryDataAccess
  final libraryDataAccess = await container.read(
    libraryDataAccessProvider.future,
  );

  // Example: Read usecases
  final getAuthorsUsecase = await container.read(
    getAuthorsUsecaseProvider.future,
  );
  final getBooksUsecase = await container.read(getBooksUsecaseProvider.future);

  // Example usage: Get all authors
  final authorsResult = await getAuthorsUsecase();

  authorsResult.fold(
    (failure) => print('Error getting authors: ${failure.message}'),
    (authors) => print('Found ${authors.length} authors'),
  );

  // Example: Get all books
  final booksResult = await getBooksUsecase();

  booksResult.fold(
    (failure) => print('Error getting books: ${failure.message}'),
    (books) => print('Found ${books.length} books'),
  );

  // Close the database
  await dbService.close();
}
