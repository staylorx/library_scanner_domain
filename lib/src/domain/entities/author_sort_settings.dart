import 'package:equatable/equatable.dart';
import 'sort_direction.dart';

/// Enum for author sort order options
enum AuthorSortOrder { name, date }

/// Model representing author sort settings
class AuthorSortSettings with EquatableMixin {
  /// The sort order for authors.
  final AuthorSortOrder order;

  /// The sort direction.
  final SortDirection direction;

  /// Creates an AuthorSortSettings instance.
  const AuthorSortSettings({
    this.order = AuthorSortOrder.name,
    this.direction = SortDirection.ascending,
  });

  /// Creates a copy of this AuthorSortSettings with optional field updates.
  AuthorSortSettings copyWith({
    AuthorSortOrder? order,
    SortDirection? direction,
  }) {
    return AuthorSortSettings(
      order: order ?? this.order,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [order, direction];
}
