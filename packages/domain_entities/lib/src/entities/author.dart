import 'package:equatable/equatable.dart';

import '../value_objects/author_id_pair.dart';

/// Represents an author.
class Author with EquatableMixin {
  /// Entity identifier.
  final String id;

  /// Business identifiers.
  final List<AuthorIdPair> businessIds;

  /// Author name.
  final String name;

  /// Author biography.
  final String? biography;

  /// Creates Author.
  Author({
    required this.id,
    required this.businessIds,
    required this.name,
    this.biography,
  });

  /// Creates a copy with optional updates.
  Author copyWith({
    String? id,
    List<AuthorIdPair>? businessIds,
    String? name,
    String? biography,
  }) {
    return Author(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      name: name ?? this.name,
      biography: biography ?? this.biography,
    );
  }

  @override
  List<Object?> get props => [id, businessIds, name, biography];
}
