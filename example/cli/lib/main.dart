// ignore_for_file: avoid_print, unused_local_variable

import 'package:dio/dio.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'image_service_impl.dart';

void main() async {
  // Initialize Dio for API calls
  final dio = Dio();

  // Create BookApiService
  final bookApiServiceFactory = BookApiServiceFactory();
  final bookApiService = bookApiServiceFactory.createBookApiService(dio);

  // Create ImageService implementation for CLI
  final imageService = CliImageService(dio);

  // Create LibraryFactory using Sembast (in-memory for demo)
  final libraryFactory = LibraryFactory.sembast(
    null, // null for in-memory database
    apiService: bookApiService,
    imageService: imageService,
  );

  // Create repositories
  final authorRepository = await libraryFactory.createAuthorRepository();
  final bookRepository = await libraryFactory.createBookRepository();
  final tagRepository = await libraryFactory.createTagRepository();
  final bookMetadataRepository = await libraryFactory
      .createBookMetadataRepository();

  // Create services
  final authorFilteringService = libraryFactory.createAuthorFilteringService();
  final authorSortingService = libraryFactory.createAuthorSortingService();
  final bookFilteringService = libraryFactory.createBookFilteringService();
  final bookSortingService = libraryFactory.createBookSortingService();
  final authorIdRegistryService = libraryFactory
      .createAuthorIdRegistryService();
  final bookIdRegistryService = libraryFactory.createBookIdRegistryService();
  final authorValidationService = libraryFactory
      .createAuthorValidationService();
  final bookValidationService = libraryFactory.createBookValidationService();

  // Create LibraryDataAccess
  final libraryDataAccess = await libraryFactory.createLibraryDataAccess();

  // Example: Create usecases
  final getAuthorsUsecase = GetAuthorsUsecase(
    authorRepository: authorRepository,
  );
  final getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);

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
  await libraryFactory.close();
}
