import '../entities/author.dart';
import '../entities/author_sort_settings.dart';
import '../entities/sort_direction.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for sorting a list of authors based on provided settings.
class GetSortedAuthorsUsecase with Loggable {
  /// Sorts the given list of authors according to the sort settings.
  List<Author> call(List<Author> authors, AuthorSortSettings settings) {
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
  }
}
