import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Concrete implementation of author filtering service
class AuthorFilteringServiceImpl implements AuthorFilteringService {
  @override
  Either<Failure, List<Author>> filterAuthors({
    required List<Author> authors,
    required String searchQuery,
  }) {
    try {
      if (searchQuery.isEmpty) {
        return Right(authors);
      }

      final query = searchQuery.toLowerCase();
      final filteredAuthors = authors.where((author) {
        return author.name.toLowerCase().contains(query);
      }).toList();

      return Right(filteredAuthors);
    } catch (e) {
      return Left(ServiceFailure('Failed to filter authors: $e'));
    }
  }
}
