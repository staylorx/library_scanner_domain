import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Usecase for filtering authors based on search query
class FilterAuthorsUsecase {
  final AbstractAuthorFilteringService _authorFilteringService;

  /// Creates a new instance of [FilterAuthorsUsecase]
  FilterAuthorsUsecase(this._authorFilteringService);

  /// Filters authors based on the search query
  Either<Failure, List<Author>> call({
    required List<Author> authors,
    required String searchQuery,
  }) {
    return _authorFilteringService.filterAuthors(
      authors: authors,
      searchQuery: searchQuery,
    );
  }
}
