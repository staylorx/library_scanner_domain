import 'package:equatable/equatable.dart';
import 'sort_direction.dart';

/// Author sort order options.
enum AuthorSortOrder { name, date }

/// Author sort settings.
class AuthorSortSettings with EquatableMixin {
  /// Sort order.
  final AuthorSortOrder order;

  /// Sort direction.
  final SortDirection direction;

  /// Creates AuthorSortSettings.
  const AuthorSortSettings({
    this.order = AuthorSortOrder.name,
    this.direction = SortDirection.ascending,
  });

  /// Creates a copy with optional updates.
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
