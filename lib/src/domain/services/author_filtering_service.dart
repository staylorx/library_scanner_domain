import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for filtering authors
abstract class AuthorFilteringService {
  /// Filters authors based on the search query
  Either<Failure, List<Author>> filterAuthors({
    required List<Author> authors,
    required String searchQuery,
  });
}
