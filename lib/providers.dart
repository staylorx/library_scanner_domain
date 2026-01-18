import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'src/data/book_api/datasources/book_api_service.dart';
import 'src/data/id_registry/services/book_id_registry_service.dart';
import 'src/data/core/repositories/author_repository_impl.dart';
import 'src/data/core/repositories/book_metadata_repository_impl.dart';
import 'src/data/core/repositories/book_repository_impl.dart';
import 'src/data/core/repositories/tag_repository_impl.dart';
import 'src/data/sembast/datasources/author_datasource.dart';
import 'src/data/sembast/datasources/book_datasource.dart';
import 'src/data/sembast/datasources/tag_datasource.dart';
import 'src/data/core/services/author_filtering_service.dart';
import 'src/data/core/services/author_sorting_service.dart';
import 'src/data/core/services/book_sorting_service.dart';
import 'src/data/core/services/book_filtering_service.dart';
import 'src/data/core/services/author_validation_service.dart';
import 'src/data/core/services/book_validation_service.dart';
import 'src/data/id_registry/services/author_id_registry_service.dart';
import 'src/domain/domain.dart';

// External dependencies providers (to be overridden by users)
final dioProvider = Provider<Dio>(
  (ref) => throw UnimplementedError('Provide Dio instance'),
);
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => throw UnimplementedError('Provide DatabaseService instance'),
);
final unitOfWorkProvider = Provider<UnitOfWork>(
  (ref) => throw UnimplementedError('Provide UnitOfWork instance'),
);
final imageServiceProvider = Provider<ImageService>(
  (ref) => throw UnimplementedError('Provide ImageService instance'),
);

// BookApiService provider
final bookApiServiceProvider = Provider<BookApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return BookApiServiceImpl(dio: dio);
});

// ID Registry Services
final authorIdRegistryServiceProvider = Provider<AuthorIdRegistryService>(
  (ref) => AuthorIdRegistryServiceImpl(),
);
final bookIdRegistryServiceProvider = Provider<BookIdRegistryService>(
  (ref) => BookIdRegistryServiceImpl(),
);

// Datasources
final authorDatasourceProvider = Provider<AuthorDatasource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return AuthorDatasource(dbService: dbService);
});

final bookDatasourceProvider = Provider<BookDatasource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return BookDatasource(dbService: dbService);
});

final tagDatasourceProvider = Provider<TagDatasource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return TagDatasource(dbService: dbService);
});

// Repositories
final authorRepositoryProvider = FutureProvider<AuthorRepository>((ref) async {
  final datasource = ref.watch(authorDatasourceProvider);
  final unitOfWork = ref.watch(unitOfWorkProvider);
  return AuthorRepositoryImpl(
    authorDatasource: datasource,
    unitOfWork: unitOfWork,
  );
});

final bookRepositoryProvider = FutureProvider<BookRepository>((ref) async {
  final bookDatasource = ref.watch(bookDatasourceProvider);
  final authorDatasource = ref.watch(authorDatasourceProvider);
  final tagDatasource = ref.watch(tagDatasourceProvider);
  final idRegistryService = ref.watch(bookIdRegistryServiceProvider);
  final unitOfWork = ref.watch(unitOfWorkProvider);
  return BookRepositoryImpl(
    bookDatasource: bookDatasource,
    authorDatasource: authorDatasource,
    tagDatasource: tagDatasource,
    idRegistryService: idRegistryService,
    unitOfWork: unitOfWork,
  );
});

final bookMetadataRepositoryProvider = FutureProvider<BookMetadataRepository>((
  ref,
) async {
  final apiService = ref.watch(bookApiServiceProvider);
  final imageService = ref.watch(imageServiceProvider);
  return BookMetadataRepositoryImpl(
    apiService: apiService,
    imageService: imageService,
  );
});

final tagRepositoryProvider = FutureProvider<TagRepository>((ref) async {
  final tagDatasource = ref.watch(tagDatasourceProvider);
  final unitOfWork = ref.watch(unitOfWorkProvider);
  return TagRepositoryImpl(
    tagDatasource: tagDatasource,
    unitOfWork: unitOfWork,
  );
});

// Services
final authorFilteringServiceProvider = Provider<AuthorFilteringService>((ref) {
  return AuthorFilteringServiceImpl();
});

final authorSortingServiceProvider = Provider<AuthorSortingService>((ref) {
  return AuthorSortingServiceImpl();
});

final bookSortingServiceProvider = Provider<BookSortingService>((ref) {
  return BookSortingServiceImpl();
});

final bookFilteringServiceProvider = Provider<BookFilteringService>((ref) {
  return BookFilteringServiceImpl();
});

final authorValidationServiceProvider = Provider<AuthorValidationService>((
  ref,
) {
  final idRegistryService = ref.watch(authorIdRegistryServiceProvider);
  return AuthorValidationServiceImpl(idRegistryService: idRegistryService);
});

final bookValidationServiceProvider = Provider<BookValidationService>((ref) {
  final idRegistryService = ref.watch(bookIdRegistryServiceProvider);
  return BookValidationServiceImpl(idRegistryService: idRegistryService);
});

// LibraryDataAccess
final libraryDataAccessProvider = FutureProvider<LibraryDataAccess>((
  ref,
) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  final unitOfWork = ref.watch(unitOfWorkProvider);
  final dbService = ref.watch(databaseServiceProvider);
  final authorIdRegistryService = ref.watch(authorIdRegistryServiceProvider);
  final bookIdRegistryService = ref.watch(bookIdRegistryServiceProvider);
  return LibraryDataAccess(
    unitOfWork: unitOfWork,
    databaseService: dbService,
    authorRepository: authorRepository,
    bookRepository: bookRepository,
    tagRepository: tagRepository,
    authorIdRegistryService: authorIdRegistryService,
    bookIdRegistryService: bookIdRegistryService,
  );
});

// Usecases
final addAuthorUsecaseProvider = FutureProvider<AddAuthorUsecase>((ref) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  final idRegistryService = ref.watch(authorIdRegistryServiceProvider);
  return AddAuthorUsecase(
    authorRepository: authorRepository,
    idRegistryService: idRegistryService,
  );
});

final addBookUsecaseProvider = FutureProvider<AddBookUsecase>((ref) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  final isBookDuplicateUsecase = ref.watch(isBookDuplicateUsecaseProvider);
  final bookIdRegistryService = ref.watch(bookIdRegistryServiceProvider);
  return AddBookUsecase(
    bookRepository: bookRepository,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
    bookIdRegistryService: bookIdRegistryService,
  );
});

final addTagUsecaseProvider = FutureProvider<AddTagUsecase>((ref) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return AddTagUsecase(tagRepository: tagRepository);
});

final clearLibraryUsecaseProvider = FutureProvider<ClearLibraryUsecase>((
  ref,
) async {
  final dataAccess = await ref.watch(libraryDataAccessProvider.future);
  return ClearLibraryUsecase(dataAccess: dataAccess);
});

final exportLibraryUsecaseProvider = FutureProvider<ExportLibraryUsecase>((
  ref,
) async {
  final dataAccess = await ref.watch(libraryDataAccessProvider.future);
  return ExportLibraryUsecase(dataAccess: dataAccess);
});

final fetchBookMetadataByIsbnUsecaseProvider =
    FutureProvider<FetchBookMetadataByIsbnUsecase>((ref) async {
      final bookMetadataRepository = await ref.watch(
        bookMetadataRepositoryProvider.future,
      );
      return FetchBookMetadataByIsbnUsecase(
        bookMetadataRepository: bookMetadataRepository,
      );
    });

final filterAuthorsUsecaseProvider = Provider<FilterAuthorsUsecase>((ref) {
  final authorFilteringService = ref.watch(authorFilteringServiceProvider);
  return FilterAuthorsUsecase(authorFilteringService);
});

final filterBooksUsecaseProvider = Provider<FilterBooksUsecase>((ref) {
  final bookFilteringService = ref.watch(bookFilteringServiceProvider);
  return FilterBooksUsecase(bookFilteringService);
});

final getAuthorByNameUsecaseProvider = FutureProvider<GetAuthorByNameUsecase>((
  ref,
) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  return GetAuthorByNameUsecase(authorRepository: authorRepository);
});

final getAuthorsByNamesUsecaseProvider =
    FutureProvider<GetAuthorsByNamesUsecase>((ref) async {
      final authorRepository = await ref.watch(authorRepositoryProvider.future);
      return GetAuthorsByNamesUsecase(authorRepository: authorRepository);
    });

final getAuthorsUsecaseProvider = FutureProvider<GetAuthorsUsecase>((
  ref,
) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  return GetAuthorsUsecase(authorRepository: authorRepository);
});

final getBookByIdPairUsecaseProvider = FutureProvider<GetBookByIdPairUsecase>((
  ref,
) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  return GetBookByIdPairUsecase(bookRepository: bookRepository);
});

final getBooksByAuthorUsecaseProvider = FutureProvider<GetBooksByAuthorUseCase>(
  (ref) async {
    final bookRepository = await ref.watch(bookRepositoryProvider.future);
    return GetBooksByAuthorUseCase(bookRepository: bookRepository);
  },
);

final getBooksByTagUsecaseProvider = FutureProvider<GetBooksByTagUseCase>((
  ref,
) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  return GetBooksByTagUseCase(bookRepository: bookRepository);
});

final getBooksUsecaseProvider = FutureProvider<GetBooksUsecase>((ref) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  return GetBooksUsecase(bookRepository: bookRepository);
});

final getLibraryStatsUsecaseProvider = FutureProvider<GetLibraryStatsUsecase>((
  ref,
) async {
  final dataAccess = await ref.watch(libraryDataAccessProvider.future);
  return GetLibraryStatsUsecase(dataAccess: dataAccess);
});

final getSortedAuthorsUsecaseProvider = Provider<GetSortedAuthorsUsecase>((
  ref,
) {
  final sortingService = ref.watch(authorSortingServiceProvider);
  return GetSortedAuthorsUsecase(sortingService: sortingService);
});

final getSortedBooksUsecaseProvider = Provider<GetSortedBooksUsecase>((ref) {
  final sortingService = ref.watch(bookSortingServiceProvider);
  return GetSortedBooksUsecase(sortingService: sortingService);
});

final getTagByNameUsecaseProvider = FutureProvider<GetTagByNameUsecase>((
  ref,
) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return GetTagByNameUsecase(tagRepository: tagRepository);
});

final getTagsByNamesUsecaseProvider = FutureProvider<GetTagsByNamesUsecase>((
  ref,
) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return GetTagsByNamesUsecase(tagRepository: tagRepository);
});

final getTagsUsecaseProvider = FutureProvider<GetTagsUsecase>((ref) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return GetTagsUsecase(tagRepository: tagRepository);
});

final importLibraryUsecaseProvider = FutureProvider<ImportLibraryUsecase>((
  ref,
) async {
  final dataAccess = await ref.watch(libraryDataAccessProvider.future);
  final isBookDuplicateUsecase = ref.watch(isBookDuplicateUsecaseProvider);
  return ImportLibraryUsecase(
    dataAccess: dataAccess,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
  );
});

final isBookDuplicateUsecaseProvider = Provider<IsBookDuplicateUsecase>((ref) {
  return IsBookDuplicateUsecase();
});

final refetchBookCoversUsecaseProvider =
    FutureProvider<RefetchBookCoversUsecase>((ref) async {
      final bookRepository = await ref.watch(bookRepositoryProvider.future);
      final fetchBookMetadataByIsbnUsecase = await ref.watch(
        fetchBookMetadataByIsbnUsecaseProvider.future,
      );
      final imageService = ref.watch(imageServiceProvider);
      return RefetchBookCoversUsecase(
        bookRepository: bookRepository,
        fetchBookMetadataByIsbnUsecase: fetchBookMetadataByIsbnUsecase,
        imageService: imageService,
      );
    });

final scanAndAddBookUsecaseProvider = FutureProvider<ScanAndAddBookUsecase>((
  ref,
) async {
  final fetchMetadataUsecase = await ref.watch(
    fetchBookMetadataByIsbnUsecaseProvider.future,
  );
  final addBookUsecase = await ref.watch(addBookUsecaseProvider.future);
  final getByIdPairUsecase = await ref.watch(
    getBookByIdPairUsecaseProvider.future,
  );
  return ScanAndAddBookUsecase(
    fetchMetadataUsecase: fetchMetadataUsecase,
    addBookUsecase: addBookUsecase,
    getByIdPairUsecase: getByIdPairUsecase,
  );
});

final validateBookUsecaseProvider = Provider<ValidateBookUsecase>((ref) {
  final bookValidationService = ref.watch(bookValidationServiceProvider);
  return ValidateBookUsecase(bookValidationService: bookValidationService);
});

// Update usecases
final updateAuthorUsecaseProvider = FutureProvider<UpdateAuthorUsecase>((
  ref,
) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  return UpdateAuthorUsecase(authorRepository: authorRepository);
});

final updateBookUsecaseProvider = FutureProvider<UpdateBookUsecase>((
  ref,
) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  return UpdateBookUsecase(bookRepository: bookRepository);
});

final updateTagUsecaseProvider = FutureProvider<UpdateTagUsecase>((ref) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return UpdateTagUsecase(tagRepository: tagRepository);
});

// Delete usecases
final deleteAuthorUsecaseProvider = FutureProvider<DeleteAuthorUsecase>((
  ref,
) async {
  final authorRepository = await ref.watch(authorRepositoryProvider.future);
  return DeleteAuthorUsecase(authorRepository: authorRepository);
});

final deleteBookUsecaseProvider = FutureProvider<DeleteBookUsecase>((
  ref,
) async {
  final bookRepository = await ref.watch(bookRepositoryProvider.future);
  return DeleteBookUsecase(bookRepository: bookRepository);
});

final deleteTagUsecaseProvider = FutureProvider<DeleteTagUsecase>((ref) async {
  final tagRepository = await ref.watch(tagRepositoryProvider.future);
  return DeleteTagUsecase(tagRepository: tagRepository);
});
