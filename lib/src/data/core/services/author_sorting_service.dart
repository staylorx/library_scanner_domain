import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of author sorting service
class AuthorSortingServiceImpl with Loggable implements AuthorSortingService {
  @override
  Either<Failure, List<Author>> sortAuthors({
    required List<Author> authors,
    required AuthorSortSettings settings,
    Logger? logger,
  }) {
    return Either.tryCatch(() {
      final sortedAuthors = authors
        ..sort((a, b) {
          int compare;
          switch (settings.order) {
            case AuthorSortOrder.name:
              compare = a.name.compareTo(b.name);
              break;
            case AuthorSortOrder.date:
              // Assuming date-based sorting, e.g., by name or a future date field
              compare = a.name.compareTo(b.name);
              break;
          }
          return settings.direction == SortDirection.ascending
              ? compare
              : -compare;
        });
      return sortedAuthors;
    }, (error, stackTrace) => ServiceFailure('Failed to sort authors: $error'));
  }
}
