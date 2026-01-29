import 'src/data/data.dart';
import 'src/domain/domain.dart';
import 'library_domain.dart';

/// Factory for creating a [LibraryDomain] instance with all dependencies wired up manually.
/// This provides a framework-agnostic way to initialize the domain layer.
///
/// Users need to provide the external dependencies (database service and unit of work).
/// All other dependencies are created and wired internally.
class LibraryDomainFactory {
  /// Creates a fully wired [LibraryDomain] instance.
  ///
  /// [databaseService] - External database service implementation
  /// [unitOfWork] - External unit of work implementation for transaction management
  static LibraryDomain create({
    required DatabaseService databaseService,
    required UnitOfWork unitOfWork,
    LibraryFileLoader? fileLoader,
    LibraryFileWriter? fileWriter,
  }) {
    // ID Registry Services
    final authorIdRegistryService = AuthorIdRegistryServiceImpl();
    final bookIdRegistryService = BookIdRegistryServiceImpl();

    // Datasources
    final authorDatasource = AuthorDatasource(dbService: databaseService);
    final bookDatasource = BookDatasource(dbService: databaseService);
    final tagDatasource = TagDatasource(dbService: databaseService);

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
      databaseService: databaseService,
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
