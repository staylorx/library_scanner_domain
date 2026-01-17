import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../data/book_api/datasources/book_api_service.dart';
import '../utils/failure.dart';
import '../data/id_registry/services/book_id_registry_service.dart';
import '../data/sembast/datasources/sembast_database.dart';
import '../data/sembast/repositories/author_repository_impl.dart';
import '../data/sembast/repositories/book_metadata_repository_impl.dart';
import '../data/sembast/repositories/book_repository_impl.dart';
import '../data/sembast/repositories/tag_repository_impl.dart';
import '../data/sembast/unit_of_work/sembast_unit_of_work.dart';
import '../data/storage/author_datasource.dart';
import '../data/storage/book_datasource.dart';
import '../data/storage/tag_datasource.dart';
import '../data/core/services/author_filtering_service.dart';
import '../data/core/services/author_sorting_service.dart';
import '../data/core/services/book_sorting_service.dart';
import '../data/core/services/book_filtering_service.dart';
import '../data/core/services/author_validation_service.dart';
import '../data/core/services/book_validation_service.dart';
import '../data/id_registry/services/author_id_registry_service.dart';
import 'domain.dart';

/// Factory for creating domain layer instances with data implementations.
class LibraryFactory {
  final DatabaseService _dbService;
  final UnitOfWork _unitOfWork;
  final BookApiService apiService;
  final ImageService imageService;

  late final AuthorIdRegistryServiceImpl _authorIdRegistry;
  late final BookIdRegistryServiceImpl _bookIdRegistry;
  late final BookDatasource bookDatasource;
  late final AuthorDatasource authorDatasource;
  late final TagDatasource tagDatasource;

  /// Creates a LibraryFactory with the specified database service and unit of work.
  LibraryFactory({
    required DatabaseService dbService,
    required UnitOfWork unitOfWork,
    required this.apiService,
    required this.imageService,
  }) : _dbService = dbService,
       _unitOfWork = unitOfWork {
    _authorIdRegistry = AuthorIdRegistryServiceImpl();
    _bookIdRegistry = BookIdRegistryServiceImpl();
  }

  /// Convenience factory for Sembast database.
  /// If dbPath is null, uses in-memory database.
  factory LibraryFactory.sembast(
    String? dbPath, {
    required BookApiService apiService,
    required ImageService imageService,
  }) {
    final database = SembastDatabase(testDbPath: dbPath);
    final unitOfWork = SembastUnitOfWork(dbService: database);
    return LibraryFactory(
      dbService: database,
      unitOfWork: unitOfWork,
      apiService: apiService,
      imageService: imageService,
    );
  }

  Future<AuthorDatasource> getAuthorDatasource() async {
    authorDatasource = AuthorDatasource(dbService: _dbService);
    return authorDatasource;
  }

  Future<BookDatasource> getBookDatasource() async {
    bookDatasource = BookDatasource(dbService: _dbService);
    return bookDatasource;
  }

  Future<TagDatasource> getTagDatasource() async {
    tagDatasource = TagDatasource(dbService: _dbService);
    return tagDatasource;
  }

  /// Creates an AuthorRepository instance.
  Future<AuthorRepository> createAuthorRepository() async {
    final authorDatasource = AuthorDatasource(dbService: _dbService);
    return AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: _unitOfWork,
    );
  }

  /// Creates a BookRepository instance.
  Future<BookRepository> createBookRepository() async {
    final bookDatasource = BookDatasource(dbService: _dbService);
    final authorDatasource = AuthorDatasource(dbService: _dbService);
    final tagDatasource = TagDatasource(dbService: _dbService);
    return BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: _bookIdRegistry,
      unitOfWork: _unitOfWork,
    );
  }

  /// Creates a BookMetadataRepository instance.
  Future<BookMetadataRepository> createBookMetadataRepository() async {
    return BookMetadataRepositoryImpl(
      apiService: apiService,
      imageService: imageService,
    );
  }

  /// Creates a TagRepository instance.
  Future<TagRepository> createTagRepository() async {
    final tagDatasource = TagDatasource(dbService: _dbService);
    return TagRepositoryImpl(
      tagDatasource: tagDatasource,
      unitOfWork: _unitOfWork,
    );
  }

  /// Creates an UpdateBookUsecase instance.
  Future<UpdateBookUsecase> createUpdateBookUsecase() async {
    final bookRepository = await createBookRepository();
    return UpdateBookUsecase(bookRepository: bookRepository);
  }

  /// Creates an UpdateAuthorUsecase instance.
  Future<UpdateAuthorUsecase> createUpdateAuthorUsecase() async {
    final authorRepository = await createAuthorRepository();
    return UpdateAuthorUsecase(authorRepository: authorRepository);
  }

  /// Creates an UpdateTagUsecase instance.
  Future<UpdateTagUsecase> createUpdateTagUsecase() async {
    final tagRepository = await createTagRepository();
    return UpdateTagUsecase(tagRepository: tagRepository);
  }

  /// Creates a DeleteBookUsecase instance.
  Future<DeleteBookUsecase> createDeleteBookUsecase() async {
    final bookRepository = await createBookRepository();
    return DeleteBookUsecase(bookRepository: bookRepository);
  }

  /// Creates a DeleteAuthorUsecase instance.
  Future<DeleteAuthorUsecase> createDeleteAuthorUsecase() async {
    final authorRepository = await createAuthorRepository();
    return DeleteAuthorUsecase(authorRepository: authorRepository);
  }

  /// Creates a DeleteTagUsecase instance.
  Future<DeleteTagUsecase> createDeleteTagUsecase() async {
    final tagRepository = await createTagRepository();
    return DeleteTagUsecase(tagRepository: tagRepository);
  }

  /// Creates an AuthorFilteringService instance.
  AuthorFilteringService createAuthorFilteringService() {
    return AuthorFilteringServiceImpl();
  }

  /// Creates an AuthorSortingService instance.
  AuthorSortingService createAuthorSortingService() {
    return AuthorSortingServiceImpl();
  }

  /// Creates an BookSortingService instance.
  BookSortingService createBookSortingService() {
    return BookSortingServiceImpl();
  }

  /// Creates a BookFilteringService instance.
  BookFilteringService createBookFilteringService() {
    return BookFilteringServiceImpl();
  }

  /// Creates an AuthorIdRegistryService instance.
  AuthorIdRegistryService createAuthorIdRegistryService() {
    return _authorIdRegistry;
  }

  /// Creates a BookIdRegistryService instance.
  BookIdRegistryService createBookIdRegistryService() {
    return _bookIdRegistry;
  }

  /// Creates an AuthorValidationService instance.
  AuthorValidationService createAuthorValidationService() {
    return AuthorValidationServiceImpl(idRegistryService: _authorIdRegistry);
  }

  /// Creates a BookValidationService instance.
  BookValidationService createBookValidationService() {
    return BookValidationServiceImpl(idRegistryService: _bookIdRegistry);
  }

  /// Creates a LibraryDataAccess instance with all data services.
  Future<LibraryDataAccess> createLibraryDataAccess() async {
    final authorRepository = await createAuthorRepository();
    final bookRepository = await createBookRepository();
    final tagRepository = await createTagRepository();
    return LibraryDataAccess(
      unitOfWork: _unitOfWork,
      databaseService: _dbService,
      authorRepository: authorRepository,
      bookRepository: bookRepository,
      tagRepository: tagRepository,
      authorIdRegistryService: _authorIdRegistry,
      bookIdRegistryService: _bookIdRegistry,
    );
  }

  /// Creates an AddAuthorUsecase instance.
  Future<AddAuthorUsecase> createAddAuthorUsecase() async {
    final authorRepository = await createAuthorRepository();
    final authorIdRegistryService = createAuthorIdRegistryService();
    return AddAuthorUsecase(
      authorRepository: authorRepository,
      idRegistryService: authorIdRegistryService,
    );
  }

  /// Creates an AddBookUsecase instance.
  Future<AddBookUsecase> createAddBookUsecase() async {
    final bookRepository = await createBookRepository();
    final isBookDuplicateUsecase = createIsBookDuplicateUsecase();
    final bookIdRegistryService = createBookIdRegistryService();
    return AddBookUsecase(
      bookRepository: bookRepository,
      isBookDuplicateUsecase: isBookDuplicateUsecase,
      bookIdRegistryService: bookIdRegistryService,
    );
  }

  /// Creates an AddTagUsecase instance.
  Future<AddTagUsecase> createAddTagUsecase() async {
    final tagRepository = await createTagRepository();
    return AddTagUsecase(tagRepository: tagRepository);
  }

  /// Creates a ClearLibraryUsecase instance.
  Future<ClearLibraryUsecase> createClearLibraryUsecase() async {
    final libraryDataAccess = await createLibraryDataAccess();
    return ClearLibraryUsecase(dataAccess: libraryDataAccess);
  }

  /// Creates an ExportLibraryUsecase instance.
  Future<ExportLibraryUsecase> createExportLibraryUsecase() async {
    final libraryDataAccess = await createLibraryDataAccess();
    return ExportLibraryUsecase(dataAccess: libraryDataAccess);
  }

  /// Creates a FetchBookMetadataByIsbnUsecase instance.
  Future<FetchBookMetadataByIsbnUsecase>
  createFetchBookMetadataByIsbnUsecase() async {
    final bookMetadataRepository = await createBookMetadataRepository();
    return FetchBookMetadataByIsbnUsecase(
      bookMetadataRepository: bookMetadataRepository,
    );
  }

  /// Creates a FilterAuthorsUsecase instance.
  FilterAuthorsUsecase createFilterAuthorsUsecase() {
    final authorFilteringService = createAuthorFilteringService();
    return FilterAuthorsUsecase(authorFilteringService);
  }

  /// Creates a FilterBooksUsecase instance.
  FilterBooksUsecase createFilterBooksUsecase() {
    final bookFilteringService = createBookFilteringService();
    return FilterBooksUsecase(bookFilteringService);
  }

  /// Creates a GetAuthorByNameUsecase instance.
  Future<GetAuthorByNameUsecase> createGetAuthorByNameUsecase() async {
    final authorRepository = await createAuthorRepository();
    return GetAuthorByNameUsecase(authorRepository: authorRepository);
  }

  /// Creates a GetAuthorsByNamesUsecase instance.
  Future<GetAuthorsByNamesUsecase> createGetAuthorsByNamesUsecase() async {
    final authorRepository = await createAuthorRepository();
    return GetAuthorsByNamesUsecase(authorRepository: authorRepository);
  }

  /// Creates a GetAuthorsUsecase instance.
  Future<GetAuthorsUsecase> createGetAuthorsUsecase() async {
    final authorRepository = await createAuthorRepository();
    return GetAuthorsUsecase(authorRepository: authorRepository);
  }

  /// Creates a GetBookByIdPairUsecase instance.
  Future<GetBookByIdPairUsecase> createGetBookByIdpairUsecase() async {
    final bookRepository = await createBookRepository();
    return GetBookByIdPairUsecase(bookRepository: bookRepository);
  }

  /// Creates a GetBooksByAuthorUseCase instance.
  Future<GetBooksByAuthorUseCase> createGetBooksByAuthorUsecase() async {
    final bookRepository = await createBookRepository();
    return GetBooksByAuthorUseCase(bookRepository: bookRepository);
  }

  /// Creates a GetBooksByTagUseCase instance.
  Future<GetBooksByTagUseCase> createGetBooksByTagUsecase() async {
    final bookRepository = await createBookRepository();
    return GetBooksByTagUseCase(bookRepository: bookRepository);
  }

  /// Creates a GetBooksUsecase instance.
  Future<GetBooksUsecase> createGetBooksUsecase() async {
    final bookRepository = await createBookRepository();
    return GetBooksUsecase(bookRepository: bookRepository);
  }

  /// Creates a GetLibraryStatsUsecase instance.
  Future<GetLibraryStatsUsecase> createGetLibraryStatsUsecase() async {
    final libraryDataAccess = await createLibraryDataAccess();
    return GetLibraryStatsUsecase(dataAccess: libraryDataAccess);
  }

  /// Creates a GetSortedAuthorsUsecase instance.
  GetSortedAuthorsUsecase createGetSortedAuthorsUsecase() {
    final authorSortingService = createAuthorSortingService();
    return GetSortedAuthorsUsecase(sortingService: authorSortingService);
  }

  /// Creates a GetSortedBooksUsecase instance.
  GetSortedBooksUsecase createGetSortedBooksUsecase() {
    final bookSortingService = createBookSortingService();
    return GetSortedBooksUsecase(sortingService: bookSortingService);
  }

  /// Creates a GetTagByNameUsecase instance.
  Future<GetTagByNameUsecase> createGetTagByNameUsecase() async {
    final tagRepository = await createTagRepository();
    return GetTagByNameUsecase(tagRepository: tagRepository);
  }

  /// Creates a GetTagsByNamesUsecase instance.
  Future<GetTagsByNamesUsecase> createGetTagsByNamesUsecase() async {
    final tagRepository = await createTagRepository();
    return GetTagsByNamesUsecase(tagRepository: tagRepository);
  }

  /// Creates a GetTagsUsecase instance.
  Future<GetTagsUsecase> createGetTagsUsecase() async {
    final tagRepository = await createTagRepository();
    return GetTagsUsecase(tagRepository: tagRepository);
  }

  /// Creates an ImportLibraryUsecase instance.
  Future<ImportLibraryUsecase> createImportLibraryUsecase() async {
    final libraryDataAccess = await createLibraryDataAccess();
    final isBookDuplicateUsecase = createIsBookDuplicateUsecase();
    return ImportLibraryUsecase(
      dataAccess: libraryDataAccess,
      isBookDuplicateUsecase: isBookDuplicateUsecase,
    );
  }

  /// Creates an IsBookDuplicateUsecase instance.
  IsBookDuplicateUsecase createIsBookDuplicateUsecase() {
    return IsBookDuplicateUsecase();
  }

  /// Creates a RefetchBookCoversUsecase instance.
  Future<RefetchBookCoversUsecase> createRefetchBookCoversUsecase() async {
    final bookRepository = await createBookRepository();
    final fetchBookMetadataByIsbnUsecase =
        await createFetchBookMetadataByIsbnUsecase();
    return RefetchBookCoversUsecase(
      bookRepository: bookRepository,
      fetchBookMetadataByIsbnUsecase: fetchBookMetadataByIsbnUsecase,
      imageService: imageService,
    );
  }

  /// Creates a ScanAndAddBookUsecase instance.
  Future<ScanAndAddBookUsecase> createScanAndAddBookUsecase() async {
    final fetchBookMetadataByIsbnUsecase =
        await createFetchBookMetadataByIsbnUsecase();
    final addBookUsecase = await createAddBookUsecase();
    final getBookByIdpairUsecase = await createGetBookByIdpairUsecase();
    return ScanAndAddBookUsecase(
      fetchMetadataUsecase: fetchBookMetadataByIsbnUsecase,
      addBookUsecase: addBookUsecase,
      getByIdPairUsecase: getBookByIdpairUsecase,
    );
  }

  /// Creates a ValidateBookUsecase instance.
  ValidateBookUsecase createValidateBookUsecase() {
    final bookValidationService = createBookValidationService();
    return ValidateBookUsecase(bookValidationService: bookValidationService);
  }

  /// Closes the database connection.
  Future<Either<Failure, Unit>> close() async {
    return _dbService.close();
  }
}

/// Factory for creating BookApiService.
class BookApiServiceFactory {
  /// Creates a BookApiService instance with the provided Dio client.
  BookApiService createBookApiService(Dio dio) {
    return BookApiServiceImpl(dio: dio);
  }
}
