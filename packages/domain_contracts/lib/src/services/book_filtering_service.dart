import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for filtering books
abstract class BookFilteringService {
  /// Filters books based on the provided filters
  TaskEither<Failure, List<Book>> filterBooks({
    required List<Book> books,
    required List<Tag> tags,
    required String searchQuery,
    required List<String> selectedTagIds,
    required bool isInclusiveFilter,
  });
}
