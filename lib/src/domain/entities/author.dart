import 'package:equatable/equatable.dart';

import '../value_objects/author_id_pair.dart';

/// A domain entity representing an author.
class Author with EquatableMixin {
  /// The business identifiers for the author.
  final List<AuthorIdPair> businessIds;

  /// The name of the author.
  final String name;

  /// The biography of the author.
  final String? biography;

  /// Creates an [Author] instance.
  Author({required this.businessIds, required this.name, this.biography});

  /// Creates a copy of this [Author] with optional field updates.
  Author copyWith({
    List<AuthorIdPair>? businessIds,
    String? name,
    String? biography,
  }) {
    return Author(
      businessIds: businessIds ?? this.businessIds,
      name: name ?? this.name,
      biography: biography ?? this.biography,
    );
  }

  @override
  List<Object?> get props => [businessIds, name, biography];
}
