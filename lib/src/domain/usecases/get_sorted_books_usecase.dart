import '../entities/book.dart';
import '../entities/book_sort_settings.dart';
import '../entities/sort_direction.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for sorting a list of books based on provided settings.
class GetSortedBooksUsecase with Loggable {
  /// Sorts the given list of books according to the sort settings.
  List<Book> call(List<Book> books, BookSortSettings settings) {
    final sortedBooks = books
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
  }
}
