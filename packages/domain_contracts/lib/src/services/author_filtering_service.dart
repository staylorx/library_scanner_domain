import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for filtering authors
abstract class AuthorFilteringService {
  /// Filters authors based on the search query
  TaskEither<Failure, List<Author>> filterAuthors({
    required List<Author> authors,
    required String searchQuery,
  });
}
