import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
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
