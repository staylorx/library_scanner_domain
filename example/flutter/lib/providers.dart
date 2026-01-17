import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path_provider/path_provider.dart';
import 'flutter_image_service.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) => Dio());

// BookApiService provider
final bookApiServiceProvider = Provider<BookApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final factory = BookApiServiceFactory();
  return factory.createBookApiService(dio);
});

// ImageService provider (using Flutter's image_picker)
final imageServiceProvider = Provider<ImageService>((ref) {
  final dio = ref.watch(dioProvider);
  return FlutterImageService(dio);
});

// Database path provider
final databasePathProvider = FutureProvider<String?>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/library.db';
});

// LibraryFactory provider
final libraryFactoryProvider = FutureProvider<LibraryFactory>((ref) async {
  final apiService = ref.watch(bookApiServiceProvider);
  final imageService = ref.watch(imageServiceProvider);
  final dbPath = await ref.watch(databasePathProvider.future);

  return LibraryFactory.sembast(
    dbPath,
    apiService: apiService,
    imageService: imageService,
  );
});

// Repositories
final authorRepositoryProvider = FutureProvider<AuthorRepository>((ref) async {
  final factory = await ref.watch(libraryFactoryProvider.future);
  return factory.createAuthorRepository();
});

final bookRepositoryProvider = FutureProvider<BookRepository>((ref) async {
  final factory = await ref.watch(libraryFactoryProvider.future);
  return factory.createBookRepository();
});

final tagRepositoryProvider = FutureProvider<TagRepository>((ref) async {
  final factory = await ref.watch(libraryFactoryProvider.future);
  return factory.createTagRepository();
});

final bookMetadataRepositoryProvider = FutureProvider<BookMetadataRepository>((
  ref,
) async {
  final factory = await ref.watch(libraryFactoryProvider.future);
  return factory.createBookMetadataRepository();
});

// Services
final authorFilteringServiceProvider = Provider<AuthorFilteringService>((ref) {
  final factory = ref.watch(libraryFactoryProvider).valueOrNull;
  if (factory == null) throw StateError('LibraryFactory not initialized');
  return factory.createAuthorFilteringService();
});

final authorSortingServiceProvider = Provider<AuthorSortingService>((ref) {
  final factory = ref.watch(libraryFactoryProvider).valueOrNull;
  if (factory == null) throw StateError('LibraryFactory not initialized');
  return factory.createAuthorSortingService();
});

final bookFilteringServiceProvider = Provider<BookFilteringService>((ref) {
  final factory = ref.watch(libraryFactoryProvider).valueOrNull;
  if (factory == null) throw StateError('LibraryFactory not initialized');
  return factory.createBookFilteringService();
});

final bookSortingServiceProvider = Provider<BookSortingService>((ref) {
  final factory = ref.watch(libraryFactoryProvider).valueOrNull;
  if (factory == null) throw StateError('LibraryFactory not initialized');
  return factory.createBookSortingService();
});

// Usecases
final getAuthorsUsecaseProvider = Provider<GetAuthorsUsecase>((ref) {
  final repository = ref.watch(authorRepositoryProvider).valueOrNull;
  if (repository == null) throw StateError('AuthorRepository not initialized');
  return GetAuthorsUsecase(authorRepository: repository);
});

final getBooksUsecaseProvider = Provider<GetBooksUsecase>((ref) {
  final repository = ref.watch(bookRepositoryProvider).valueOrNull;
  if (repository == null) throw StateError('BookRepository not initialized');
  return GetBooksUsecase(bookRepository: repository);
});

// State providers for UI
final authorsProvider = FutureProvider<List<Author>>((ref) async {
  final usecase = ref.watch(getAuthorsUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (authors) => authors,
  );
});

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final usecase = ref.watch(getBooksUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (books) => books,
  );
});
