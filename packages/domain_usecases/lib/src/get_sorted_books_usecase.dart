import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// Use case for sorting a list of books based on provided settings.
class GetSortedBooksUsecase with Loggable {
  final BookSortingService sortingService;

  /// Creates a GetSortedBooksUsecase with the required sorting service.
  GetSortedBooksUsecase({required this.sortingService});

  /// Sorts the given list of books according to the sort settings.
  TaskEither<Failure, List<Book>> call(
    List<Book> books,
    BookSortSettings settings,
  ) {
    return sortingService.sortBooks(books: books, settings: settings);
  }
}
