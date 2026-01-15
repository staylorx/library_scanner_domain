import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of book filtering service
class BookFilteringServiceImpl with Loggable implements BookFilteringService {
  @override
  Either<Failure, List<Book>> filterBooks({
    required List<Book> books,
    required List<Tag> tags,
    required String searchQuery,
    required List<String> selectedTagIds,
    required bool isInclusiveFilter,
    Logger? logger,
  }) {
    return Either.tryCatch(() {
      final filteredBooks = books.where((book) {
        // Search filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          final titleMatch = book.title.toLowerCase().contains(query);
          final idPairsMatch = book.businessIds.any(
            (pair) => pair.idCode.toLowerCase().contains(query),
          );
          final authorMatch = book.authors.any(
            (author) => author.name.toLowerCase().contains(query),
          );

          if (!titleMatch && !idPairsMatch && !authorMatch) {
            return false;
          }
        }

        // Tag filter
        if (selectedTagIds.isNotEmpty) {
          if (isInclusiveFilter) {
            // Inclusive (AND) logic: Book must have ALL selected tags
            return selectedTagIds.every(
              (selectedTagId) =>
                  book.tags.any((bookTag) => bookTag.name == selectedTagId),
            );
          } else {
            // Exclusive (OR) logic: Book must have ANY of the selected tags
            return book.tags.any(
              (bookTag) => selectedTagIds.contains(bookTag.name),
            );
          }
        }

        return true;
      }).toList();

      return filteredBooks;
    }, (error, stackTrace) => ServiceFailure('Failed to filter books: $error'));
  }
}
