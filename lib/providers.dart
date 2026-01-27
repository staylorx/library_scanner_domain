import 'package:riverpod/riverpod.dart';
import 'src/data/data.dart';
import 'src/domain/domain.dart';

// External dependencies providers (to be overridden by users)
// These provide external services that the domain layer depends on
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => throw UnimplementedError('Provide DatabaseService instance'),
);
// Transaction manager for coordinating database operations
final transactionProvider = Provider<UnitOfWork>(
  (ref) => throw UnimplementedError('Provide UnitOfWork instance'),
);
// Legacy alias for backwards compatibility
final unitOfWorkProvider = transactionProvider;

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
  final unitOfWork = ref.watch(transactionProvider);
  final idRegistryService = ref.watch(authorIdRegistryServiceProvider);
  return AuthorRepositoryImpl(
    authorDatasource: datasource,
    unitOfWork: unitOfWork,
    idRegistryService: idRegistryService,
  );
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final bookDatasource = ref.watch(bookDatasourceProvider);
  final authorDatasource = ref.watch(authorDatasourceProvider);
  final tagDatasource = ref.watch(tagDatasourceProvider);
  final idRegistryService = ref.watch(bookIdRegistryServiceProvider);
  final unitOfWork = ref.watch(transactionProvider);
  return BookRepositoryImpl(
    bookDatasource: bookDatasource,
    authorDatasource: authorDatasource,
    tagDatasource: tagDatasource,
    idRegistryService: idRegistryService,
    unitOfWork: unitOfWork,
  );
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final tagDatasource = ref.watch(tagDatasourceProvider);
  final unitOfWork = ref.watch(transactionProvider);
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

// Data access service - provides bundled access to all repositories and services
final dataAccessProvider = Provider<LibraryDataAccess>((ref) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  final bookRepository = ref.watch(bookRepositoryProvider);
  final tagRepository = ref.watch(tagRepositoryProvider);
  final unitOfWork = ref.watch(transactionProvider);
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

// Legacy alias for backwards compatibility
final libraryDataAccessProvider = dataAccessProvider;

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
  return AddBookUsecase(
    bookRepository: bookRepository,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
  );
});

final addTagUsecaseProvider = Provider<AddTagUsecase>((ref) {
  final tagRepository = ref.watch(tagRepositoryProvider);
  final getTagByNameUsecase = ref.watch(getTagByNameUsecaseProvider);
  return AddTagUsecase(
    tagRepository: tagRepository,
    getTagByNameUsecase: getTagByNameUsecase,
  );
});

final clearLibraryUsecaseProvider = Provider<ClearLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  return ClearLibraryUsecase(dataAccess: dataAccess);
});

final exportLibraryUsecaseProvider = Provider<ExportLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  final fileWriter = ref.watch(libraryFileWriterProvider);
  return ExportLibraryUsecase(dataAccess: dataAccess, fileWriter: fileWriter);
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

final getAuthorByIdPairUsecaseProvider = Provider<GetAuthorByIdPairUsecase>((
  ref,
) {
  final authorRepository = ref.watch(authorRepositoryProvider);
  return GetAuthorByIdPairUsecase(authorRepository: authorRepository);
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

final libraryFileLoaderProvider = Provider<LibraryFileLoader>((ref) {
  return LibraryFileLoaderImpl();
});

final libraryFileWriterProvider = Provider<LibraryFileWriter>((ref) {
  return LibraryFileWriterImpl();
});

final importLibraryUsecaseProvider = Provider<ImportLibraryUsecase>((ref) {
  final dataAccess = ref.watch(libraryDataAccessProvider);
  final isBookDuplicateUsecase = ref.watch(isBookDuplicateUsecaseProvider);
  final fileLoader = ref.watch(libraryFileLoaderProvider);
  return ImportLibraryUsecase(
    dataAccess: dataAccess,
    isBookDuplicateUsecase: isBookDuplicateUsecase,
    fileLoader: fileLoader,
  );
});

final isAuthorDuplicateUsecaseProvider = Provider<IsAuthorDuplicateUsecase>((
  ref,
) {
  return IsAuthorDuplicateUsecase();
});

final isBookDuplicateUsecaseProvider = Provider<IsBookDuplicateUsecase>((ref) {
  return IsBookDuplicateUsecase();
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
