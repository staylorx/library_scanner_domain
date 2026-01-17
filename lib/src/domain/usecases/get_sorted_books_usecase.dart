import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for sorting a list of books based on provided settings.
class GetSortedBooksUsecase with Loggable {
  final BookSortingService _sortingService;

  /// Creates a GetSortedBooksUsecase with the required sorting service.
  GetSortedBooksUsecase({required BookSortingService sortingService})
    : _sortingService = sortingService;

  /// Sorts the given list of books according to the sort settings.
  Either<Failure, List<Book>> call(
    List<Book> books,
    BookSortSettings settings,
  ) {
    return _sortingService.sortBooks(books: books, settings: settings);
  }
}
