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
final authorRepositoryProvider = Provider<AuthorRepository>((ref) {
  final datasource = ref.watch(authorDatasourceProvider);
  final unitOfWork = ref.watch(unitOfWorkProvider);
  return AuthorRepositoryImpl(
    authorDatasource: datasource,
    unitOfWork: unitOfWork,
  );
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
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

final bookMetadataRepositoryProvider = Provider<BookMetadataRepository>((ref) {
  final apiService = ref.watch(bookApiServiceProvider);
  final imageService = ref.watch(imageServiceProvider);
  return BookMetadataRepositoryImpl(
    apiService: apiService,
    imageService: imageService,
  );
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
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
final libraryDataAccessProvider = Provider<LibraryDataAccess>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  final bookRepository = ref.watch(bookRepositoryProvider);
  final tagRepository = ref.watch(tagRepositoryProvider);
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
final addAuthorUsecaseProvider = Provider<AddAuthorUsecase>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  final idRegistryService = ref.watch(authorIdRegistryServiceProvider);
  return AddAuthorUsecase(
    authorRepository: authorRepository,
    idRegistryService: idRegistryService,
  );
});

final addBookUsecaseProvider = Provider<AddBookUsecase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final isBookDuplicateUsecase = ref.watch(isBookDuplicateUsecaseProvider);
  final bookIdRegistryService = ref.watch(bookIdRegistryServiceProvider);
  return AddBookUsecase(
    bookRepository: bookRepository,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
    bookIdRegistryService: bookIdRegistryService,
  );
});

final addTagUsecaseProvider = Provider<AddTagUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return AddTagUsecase(tagRepository: tagRepository);
});

final clearLibraryUsecaseProvider = Provider<ClearLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  return ClearLibraryUsecase(dataAccess: dataAccess);
});

final exportLibraryUsecaseProvider = Provider<ExportLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  return ExportLibraryUsecase(dataAccess: dataAccess);
});

final fetchBookMetadataByIsbnUsecaseProvider =
    Provider<FetchBookMetadataByIsbnUsecase>((ref) {
      final bookMetadataRepository = ref.watch(bookMetadataRepositoryProvider);
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

final getAuthorByNameUsecaseProvider = Provider<GetAuthorByNameUsecase>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return GetAuthorByNameUsecase(authorRepository: authorRepository);
});

final getAuthorsByNamesUsecaseProvider = Provider<GetAuthorsByNamesUsecase>((
  ref,
) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return GetAuthorsByNamesUsecase(authorRepository: authorRepository);
});

final getAuthorsUsecaseProvider = Provider<GetAuthorsUsecase>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return GetAuthorsUsecase(authorRepository: authorRepository);
});

final getBookByIdPairUsecaseProvider = Provider<GetBookByIdPairUsecase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return GetBookByIdPairUsecase(bookRepository: bookRepository);
});

final getBooksByAuthorUsecaseProvider = Provider<GetBooksByAuthorUseCase>((
  ref,
) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return GetBooksByAuthorUseCase(bookRepository: bookRepository);
});

final getBooksByTagUsecaseProvider = Provider<GetBooksByTagUseCase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return GetBooksByTagUseCase(bookRepository: bookRepository);
});

final getBooksUsecaseProvider = Provider<GetBooksUsecase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return GetBooksUsecase(bookRepository: bookRepository);
});

final getLibraryStatsUsecaseProvider = Provider<GetLibraryStatsUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
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

final getTagByNameUsecaseProvider = Provider<GetTagByNameUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return GetTagByNameUsecase(tagRepository: tagRepository);
});

final getTagsByNamesUsecaseProvider = Provider<GetTagsByNamesUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return GetTagsByNamesUsecase(tagRepository: tagRepository);
});

final getTagsUsecaseProvider = Provider<GetTagsUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return GetTagsUsecase(tagRepository: tagRepository);
});

final importLibraryUsecaseProvider = Provider<ImportLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  final isBookDuplicateUsecase = ref.watch(isBookDuplicateUsecaseProvider);
  return ImportLibraryUsecase(
    dataAccess: dataAccess,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
  );
});

final isBookDuplicateUsecaseProvider = Provider<IsBookDuplicateUsecase>((ref) {
  return IsBookDuplicateUsecase();
});

final refetchBookCoversUsecaseProvider = Provider<RefetchBookCoversUsecase>((
  ref,
) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final fetchBookMetadataByIsbnUsecase = ref.watch(
    fetchBookMetadataByIsbnUsecaseProvider,
  );
  final imageService = ref.watch(imageServiceProvider);
  return RefetchBookCoversUsecase(
    bookRepository: bookRepository,
    fetchBookMetadataByIsbnUsecase: fetchBookMetadataByIsbnUsecase,
    imageService: imageService,
  );
});

final scanAndAddBookUsecaseProvider = Provider<ScanAndAddBookUsecase>((ref) {
  final fetchMetadataUsecase = ref.watch(
    fetchBookMetadataByIsbnUsecaseProvider,
  );
  final addBookUsecase = ref.watch(addBookUsecaseProvider);
  final getByIdPairUsecase = ref.watch(getBookByIdPairUsecaseProvider);
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
final updateAuthorUsecaseProvider = Provider<UpdateAuthorUsecase>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return UpdateAuthorUsecase(authorRepository: authorRepository);
});

final updateBookUsecaseProvider = Provider<UpdateBookUsecase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return UpdateBookUsecase(bookRepository: bookRepository);
});

final updateTagUsecaseProvider = Provider<UpdateTagUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return UpdateTagUsecase(tagRepository: tagRepository);
});

// Delete usecases
final deleteAuthorUsecaseProvider = Provider<DeleteAuthorUsecase>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return DeleteAuthorUsecase(authorRepository: authorRepository);
});

final deleteBookUsecaseProvider = Provider<DeleteBookUsecase>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return DeleteBookUsecase(bookRepository: bookRepository);
});

final deleteTagUsecaseProvider = Provider<DeleteTagUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  return DeleteTagUsecase(tagRepository: tagRepository);
});
