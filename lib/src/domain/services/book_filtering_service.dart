import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for filtering books
abstract class BookFilteringService {
  /// Filters books based on the provided filters
  Either<Failure, List<Book>> filterBooks({
    required List<Book> books,
    required List<Tag> tags,
    required String searchQuery,
    required List<String> selectedTagIds,
    required bool isInclusiveFilter,
  });
}
