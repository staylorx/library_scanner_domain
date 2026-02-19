import 'package:domain_usecases/domain_usecase.dart';

import 'src/domain/domain.dart';

/// Facade class that provides access to all domain usecases.
/// This is the main entry point for using the library scanner domain.
/// Users should create an instance using [LibraryDomainFactory.create].
class LibraryDomain {
  // Author usecases
  final AddAuthorUsecase addAuthorUsecase;
  final DeleteAuthorUsecase deleteAuthorUsecase;
  final UpdateAuthorUsecase updateAuthorUsecase;
  final GetAuthorsUsecase getAuthorsUsecase;
  final GetAuthorByNameUsecase getAuthorByNameUsecase;
  final GetAuthorsByNamesUsecase getAuthorsByNamesUsecase;
  final GetAuthorByIdUsecase getAuthorByIdUsecase;
  final GetAuthorByIdPairUsecase getAuthorByIdPairUsecase;
  final GetSortedAuthorsUsecase getSortedAuthorsUsecase;
  final FilterAuthorsUsecase filterAuthorsUsecase;
  final IsAuthorDuplicateUsecase isAuthorDuplicateUsecase;

  // Book usecases
  final AddBookUsecase addBookUsecase;
  final DeleteBookUsecase deleteBookUsecase;
  final UpdateBookUsecase updateBookUsecase;
  final GetBooksUsecase getBooksUsecase;
  final GetBookByIdUsecase getBookByIdUsecase;
  final GetBookByIdPairUsecase getBookByIdPairUsecase;
  final GetBooksByAuthorUseCase getBooksByAuthorUsecase;
  final GetBooksByTagUseCase getBooksByTagUsecase;
  final GetSortedBooksUsecase getSortedBooksUsecase;
  final FilterBooksUsecase filterBooksUsecase;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;
  final ValidateBookUsecase validateBookUsecase;

  // Tag usecases
  final AddTagUsecase addTagUsecase;
  final DeleteTagUsecase deleteTagUsecase;
  final UpdateTagUsecase updateTagUsecase;
  final GetTagsUsecase getTagsUsecase;
  final GetTagByIdUsecase getTagByIdUsecase;
  final GetTagByNameUsecase getTagByNameUsecase;
  final GetTagsByNamesUsecase getTagsByNamesUsecase;

  // Library operations
  final ClearLibraryUsecase clearLibraryUsecase;
  final ExportLibraryUsecase exportLibraryUsecase;
  final ImportLibraryUsecase importLibraryUsecase;
  final GetLibraryStatsUsecase getLibraryStatsUsecase;

  const LibraryDomain({
    required this.addAuthorUsecase,
    required this.deleteAuthorUsecase,
    required this.updateAuthorUsecase,
    required this.getAuthorsUsecase,
    required this.getAuthorByNameUsecase,
    required this.getAuthorsByNamesUsecase,
    required this.getAuthorByIdUsecase,
    required this.getAuthorByIdPairUsecase,
    required this.getSortedAuthorsUsecase,
    required this.filterAuthorsUsecase,
    required this.isAuthorDuplicateUsecase,
    required this.addBookUsecase,
    required this.deleteBookUsecase,
    required this.updateBookUsecase,
    required this.getBooksUsecase,
    required this.getBookByIdUsecase,
    required this.getBookByIdPairUsecase,
    required this.getBooksByAuthorUsecase,
    required this.getBooksByTagUsecase,
    required this.getSortedBooksUsecase,
    required this.filterBooksUsecase,
    required this.isBookDuplicateUsecase,
    required this.validateBookUsecase,
    required this.addTagUsecase,
    required this.deleteTagUsecase,
    required this.updateTagUsecase,
    required this.getTagsUsecase,
    required this.getTagByIdUsecase,
    required this.getTagByNameUsecase,
    required this.getTagsByNamesUsecase,
    required this.clearLibraryUsecase,
    required this.exportLibraryUsecase,
    required this.importLibraryUsecase,
    required this.getLibraryStatsUsecase,
  });
}
