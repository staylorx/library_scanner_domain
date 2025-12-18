import 'package:equatable/equatable.dart';
import 'sort_direction.dart';

/// Enum for author sort order options
enum AuthorSortOrder { name, date }

/// Model representing author sort settings
class AuthorSortSettings with EquatableMixin {
  final AuthorSortOrder order;
  final SortDirection direction;

  const AuthorSortSettings({
    this.order = AuthorSortOrder.name,
    this.direction = SortDirection.ascending,
  });

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
