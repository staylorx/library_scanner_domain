import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of author filtering service
class AuthorFilteringServiceImpl
    with Loggable
    implements AuthorFilteringService {
  @override
  Either<Failure, List<Author>> filterAuthors({
    required List<Author> authors,
    required String searchQuery,
    Logger? logger,
  }) {
    return Either.tryCatch(
      () {
        if (searchQuery.isEmpty) {
          return authors;
        }

        final query = searchQuery.toLowerCase();
        final filteredAuthors = authors.where((author) {
          return author.name.toLowerCase().contains(query);
        }).toList();

        return filteredAuthors;
      },
      (error, stackTrace) => ServiceFailure('Failed to filter authors: $error'),
    );
  }
}
