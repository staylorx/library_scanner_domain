import 'package:equatable/equatable.dart';

import 'sort_direction.dart';

/// Enum for book sort order options
enum BookSortOrder { title, date }

/// Model representing book sort settings
class BookSortSettings with EquatableMixin {
  /// The sort order for books.
  final BookSortOrder order;

  /// The sort direction.
  final SortDirection direction;

  /// Creates a BookSortSettings instance.
  const BookSortSettings({
    this.order = BookSortOrder.title,
    this.direction = SortDirection.ascending,
  });

  /// Creates a copy of this BookSortSettings with optional field updates.
  BookSortSettings copyWith({BookSortOrder? order, SortDirection? direction}) {
    return BookSortSettings(
      order: order ?? this.order,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [order, direction];
}
