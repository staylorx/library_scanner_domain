import 'package:datastore_hive/datastore_hive.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_usecases/domain_usecase.dart';
import 'package:dataservice_filtering/dataservice_filtering.dart';
import 'package:datastore_files/datastore_files.dart';
import 'package:library_scanner_core/library_scanner_domain.dart';

/// Factory for creating a [LibraryDomain] instance with all Hive dependencies
/// wired up.
///
/// Callers provide a [HiveUnitOfWork] (and optionally file I/O services).
/// All internal datasources, repositories and usecases are created here.
///
/// ## No domain changes required
///
/// This factory is proof that the clean architecture is truly decoupled.
/// The domain layer (`domain_entities`, `domain_contracts`, `domain_usecases`)
/// is identical for both Sembast and Hive backends — only this factory and
/// the `datastore_hive` package differ.
class HiveDomainFactory {
  /// Creates a fully wired [LibraryDomain] backed by a Hive database.
  ///
  /// [unitOfWork] — the Hive unit of work that owns the database connection.
  /// [fileLoader] / [fileWriter] — optional overrides for file I/O (useful in tests).
  static LibraryDomain create({
    required HiveUnitOfWork unitOfWork,
    LibraryFileLoader? fileLoader,
    LibraryFileWriter? fileWriter,
  }) {
    // The HiveDatabase is not directly exposed by HiveUnitOfWork, so callers
    // must pass the HiveDatabase separately when constructing datasources.
    // To keep the factory API simple (mirrors LibraryDomainFactory), callers
    // can pass a HiveDatabase via a wrapper or construct the domain objects
    // directly. Here we require the caller to supply the HiveDatabase.
    throw UnimplementedError(
      'Use HiveDomainFactory.createWithDatabase(...) instead.',
    );
  }

  /// Creates a fully wired [LibraryDomain] backed by a [HiveDatabase].
  ///
  /// [hiveDb]     — the open (or lazy-open) Hive database instance.
  /// [unitOfWork] — the Hive unit of work (shares the same backend as [hiveDb]).
  /// [fileLoader] / [fileWriter] — optional overrides for file I/O.
  static LibraryDomain createWithDatabase({
    required HiveDatabase hiveDb,
    required HiveUnitOfWork unitOfWork,
    LibraryFileLoader? fileLoader,
    LibraryFileWriter? fileWriter,
  }) {
    // ID Registry Services
    final authorIdRegistryService = AuthorIdRegistryServiceImpl();
    final bookIdRegistryService = BookIdRegistryServiceImpl();

    // Datasources
    final authorDatasource = AuthorDatasource(hiveDb: hiveDb);
    final bookDatasource = BookDatasource(hiveDb: hiveDb);
    final tagDatasource = TagDatasource(hiveDb: hiveDb);

    // Repositories
    final authorRepository = AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: unitOfWork,
      idRegistryService: authorIdRegistryService,
    );

    final bookRepository = BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: bookIdRegistryService,
      unitOfWork: unitOfWork,
    );

    final tagRepository = TagRepositoryImpl(
      tagDatasource: tagDatasource,
      unitOfWork: unitOfWork,
    );

    // Services
    final authorFilteringService = AuthorFilteringServiceImpl();
    final authorSortingService = AuthorSortingServiceImpl();
    final bookSortingService = BookSortingServiceImpl();
    final bookFilteringService = BookFilteringServiceImpl();

    final bookValidationService = BookValidationServiceImpl(
      idRegistryService: bookIdRegistryService,
    );

    // Data access service
    final dataAccess = LibraryDataAccess(
      unitOfWork: unitOfWork,
      authorRepository: authorRepository,
      bookRepository: bookRepository,
      tagRepository: tagRepository,
      authorIdRegistryService: authorIdRegistryService,
      bookIdRegistryService: bookIdRegistryService,
    );

    // File services
    final libraryFileLoader = fileLoader ?? LibraryFileLoaderImpl();
    final libraryFileWriter = fileWriter ?? LibraryFileWriterImpl();

    // Usecases
    final addAuthorUsecase = AddAuthorUsecase(
      authorRepository: authorRepository,
      idRegistryService: authorIdRegistryService,
    );

    final addBookUsecase = AddBookUsecase(
      bookRepository: bookRepository,
      isBookDuplicateUsecase: IsBookDuplicateUsecase(),
    );

    final addTagUsecase = AddTagUsecase(
      tagRepository: tagRepository,
      getTagByNameUsecase: GetTagByNameUsecase(tagRepository: tagRepository),
    );

    final clearLibraryUsecase = ClearLibraryUsecase(dataAccess: dataAccess);

    final exportLibraryUsecase = ExportLibraryUsecase(
      dataAccess: dataAccess,
      fileWriter: libraryFileWriter,
    );

    final filterAuthorsUsecase = FilterAuthorsUsecase(authorFilteringService);

    final filterBooksUsecase = FilterBooksUsecase(bookFilteringService);

    final getAuthorByNameUsecase = GetAuthorByNameUsecase(
      authorRepository: authorRepository,
    );

    final getAuthorsByNamesUsecase = GetAuthorsByNamesUsecase(
      authorRepository: authorRepository,
    );

    final getAuthorsUsecase = GetAuthorsUsecase(
      authorRepository: authorRepository,
    );

    final getAuthorByIdUsecase = GetAuthorByIdUsecase(
      authorRepository: authorRepository,
    );

    final getAuthorByIdPairUsecase = GetAuthorByIdPairUsecase(
      authorRepository: authorRepository,
    );

    final getBookByIdUsecase = GetBookByIdUsecase(
      bookRepository: bookRepository,
    );

    final getBookByIdPairUsecase = GetBookByIdPairUsecase(
      bookRepository: bookRepository,
    );

    final getTagByIdUsecase = GetTagByIdUsecase(tagRepository: tagRepository);

    final getBooksByAuthorUsecase = GetBooksByAuthorUseCase(
      bookRepository: bookRepository,
    );

    final getBooksByTagUsecase = GetBooksByTagUseCase(
      bookRepository: bookRepository,
    );

    final getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);

    final getLibraryStatsUsecase = GetLibraryStatsUsecase(
      dataAccess: dataAccess,
    );

    final getSortedAuthorsUsecase = GetSortedAuthorsUsecase(
      sortingService: authorSortingService,
    );

    final getSortedBooksUsecase = GetSortedBooksUsecase(
      sortingService: bookSortingService,
    );

    final getTagByNameUsecase = GetTagByNameUsecase(
      tagRepository: tagRepository,
    );

    final getTagsByNamesUsecase = GetTagsByNamesUsecase(
      tagRepository: tagRepository,
    );

    final getTagsUsecase = GetTagsUsecase(tagRepository: tagRepository);

    final importLibraryUsecase = ImportLibraryUsecase(
      dataAccess: dataAccess,
      isBookDuplicateUsecase: IsBookDuplicateUsecase(),
      fileLoader: libraryFileLoader,
    );

    final isAuthorDuplicateUsecase = IsAuthorDuplicateUsecase();

    final isBookDuplicateUsecase = IsBookDuplicateUsecase();

    final validateBookUsecase = ValidateBookUsecase(
      bookValidationService: bookValidationService,
    );

    final updateAuthorUsecase = UpdateAuthorUsecase(
      authorRepository: authorRepository,
    );

    final updateBookUsecase = UpdateBookUsecase(bookRepository: bookRepository);

    final updateTagUsecase = UpdateTagUsecase(tagRepository: tagRepository);

    final deleteAuthorUsecase = DeleteAuthorUsecase(
      authorRepository: authorRepository,
    );

    final deleteBookUsecase = DeleteBookUsecase(bookRepository: bookRepository);

    final deleteTagUsecase = DeleteTagUsecase(tagRepository: tagRepository);

    return LibraryDomain(
      addAuthorUsecase: addAuthorUsecase,
      deleteAuthorUsecase: deleteAuthorUsecase,
      updateAuthorUsecase: updateAuthorUsecase,
      getAuthorsUsecase: getAuthorsUsecase,
      getAuthorByNameUsecase: getAuthorByNameUsecase,
      getAuthorsByNamesUsecase: getAuthorsByNamesUsecase,
      getAuthorByIdUsecase: getAuthorByIdUsecase,
      getAuthorByIdPairUsecase: getAuthorByIdPairUsecase,
      getSortedAuthorsUsecase: getSortedAuthorsUsecase,
      filterAuthorsUsecase: filterAuthorsUsecase,
      isAuthorDuplicateUsecase: isAuthorDuplicateUsecase,
      addBookUsecase: addBookUsecase,
      deleteBookUsecase: deleteBookUsecase,
      updateBookUsecase: updateBookUsecase,
      getBooksUsecase: getBooksUsecase,
      getBookByIdUsecase: getBookByIdUsecase,
      getBookByIdPairUsecase: getBookByIdPairUsecase,
      getBooksByAuthorUsecase: getBooksByAuthorUsecase,
      getBooksByTagUsecase: getBooksByTagUsecase,
      getSortedBooksUsecase: getSortedBooksUsecase,
      filterBooksUsecase: filterBooksUsecase,
      isBookDuplicateUsecase: isBookDuplicateUsecase,
      validateBookUsecase: validateBookUsecase,
      addTagUsecase: addTagUsecase,
      deleteTagUsecase: deleteTagUsecase,
      updateTagUsecase: updateTagUsecase,
      getTagsUsecase: getTagsUsecase,
      getTagByIdUsecase: getTagByIdUsecase,
      getTagByNameUsecase: getTagByNameUsecase,
      getTagsByNamesUsecase: getTagsByNamesUsecase,
      clearLibraryUsecase: clearLibraryUsecase,
      exportLibraryUsecase: exportLibraryUsecase,
      importLibraryUsecase: importLibraryUsecase,
      getLibraryStatsUsecase: getLibraryStatsUsecase,
    );
  }
}
