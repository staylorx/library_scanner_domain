import 'package:equatable/equatable.dart';

import 'sort_direction.dart';

/// Enum for book sort order options
enum BookSortOrder { title, date }

/// Model representing book sort settings
class BookSortSettings with EquatableMixin {
  final BookSortOrder order;
  final SortDirection direction;

  const BookSortSettings({
    this.order = BookSortOrder.title,
    this.direction = SortDirection.ascending,
  });

  BookSortSettings copyWith({BookSortOrder? order, SortDirection? direction}) {
    return BookSortSettings(
      order: order ?? this.order,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [order, direction];
}
