import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

/// Usecase for filtering authors based on search query
class FilterAuthorsUsecase with Loggable {
  final AuthorFilteringService authorFilteringService;

  /// Creates a new instance of [FilterAuthorsUsecase]
  FilterAuthorsUsecase(this.authorFilteringService);

  /// Filters authors based on the search query
  TaskEither<Failure, List<Author>> call({
    required List<Author> authors,
    required String searchQuery,
  }) {
    return authorFilteringService.filterAuthors(
      authors: authors,
      searchQuery: searchQuery,
    );
  }
}
