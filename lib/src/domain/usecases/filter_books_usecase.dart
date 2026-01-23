import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

/// Usecase for filtering books based on search query and tag filters
class FilterBooksUsecase with Loggable {
  final BookFilteringService bookFilteringService;

  /// Creates a new instance of [FilterBooksUsecase]
  FilterBooksUsecase(this.bookFilteringService);

  /// Filters books based on the provided filters
  TaskEither<Failure, List<Book>> call({
    required List<Book> books,
    required List<Tag> tags,
    required String searchQuery,
    required List<String> selectedTagIds,
    required bool isInclusiveFilter,
  }) {
    return bookFilteringService.filterBooks(
      books: books,
      tags: tags,
      searchQuery: searchQuery,
      selectedTagIds: selectedTagIds,
      isInclusiveFilter: isInclusiveFilter,
    );
  }
}
