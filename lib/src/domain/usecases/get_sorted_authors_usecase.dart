import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for sorting a list of authors based on provided settings.
class GetSortedAuthorsUsecase with Loggable {
  final AuthorSortingService _sortingService;

  /// Creates a GetSortedAuthorsUsecase with the required sorting service.
  GetSortedAuthorsUsecase({required AuthorSortingService sortingService})
    : _sortingService = sortingService;

  /// Sorts the given list of authors according to the sort settings.
  Either<Failure, List<Author>> call(
    List<Author> authors,
    AuthorSortSettings settings,
  ) {
    return _sortingService.sortAuthors(authors: authors, settings: settings);
  }
}
