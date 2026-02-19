import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of book sorting service
class BookSortingServiceImpl with Loggable implements BookSortingService {
  @override
  TaskEither<Failure, List<Book>> sortBooks({
    required List<Book> books,
    required BookSortSettings settings,
    Logger? logger,
  }) {
    return TaskEither.fromEither(
      Either.tryCatch(() {
        final sortedBooks = List<Book>.from(books)
          ..sort((a, b) {
            int compare;
            switch (settings.order) {
              case BookSortOrder.title:
                compare = a.title.compareTo(b.title);
                break;
              case BookSortOrder.date:
                compare = (a.publishedDate ?? DateTime.now()).compareTo(
                  b.publishedDate ?? DateTime.now(),
                );
                break;
            }
            return settings.direction == SortDirection.ascending
                ? compare
                : -compare;
          });
        return sortedBooks;
      }, (error, stackTrace) => ServiceFailure('Failed to sort books: $error')),
    );
  }
}
