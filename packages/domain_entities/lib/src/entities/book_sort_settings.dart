import 'package:equatable/equatable.dart';

import 'sort_direction.dart';

/// Book sort order options.
enum BookSortOrder { title, date }

/// Book sort settings.
class BookSortSettings with EquatableMixin {
  /// Sort order.
  final BookSortOrder order;

  /// Sort direction.
  final SortDirection direction;

  /// Creates BookSortSettings.
  const BookSortSettings({
    this.order = BookSortOrder.title,
    this.direction = SortDirection.ascending,
  });

  /// Creates a copy with optional updates.
  BookSortSettings copyWith({BookSortOrder? order, SortDirection? direction}) {
    return BookSortSettings(
      order: order ?? this.order,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [order, direction];
}
