import 'package:equatable/equatable.dart';

import '../value_objects/author_id_pair.dart';

/// Represents an author.
class Author with EquatableMixin {
  /// Business identifiers.
  final List<AuthorIdPair> businessIds;

  /// Author name.
  final String name;

  /// Author biography.
  final String? biography;

  /// Creates Author.
  Author({required this.businessIds, required this.name, this.biography});

  /// Creates a copy with optional updates.
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
