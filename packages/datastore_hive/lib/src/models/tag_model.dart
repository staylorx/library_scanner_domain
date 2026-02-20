import 'package:domain_entities/domain_entities.dart';

/// Data model for a tag.
class TagModel {
  /// Unique identifier.
  final String id;

  /// Tag name.
  final String name;

  /// Tag description.
  final String? description;

  /// Tag color.
  final String color;

  /// Slug version.
  final String slug;

  /// Associated book identifiers.
  final List<String> bookIds;

  /// Creates a TagModel.
  const TagModel({
    required this.id,
    required this.name,
    this.description,
    this.color = '#FF0000',
    required this.slug,
    required this.bookIds,
  });

  /// Creates from map.
  factory TagModel.fromMap({required Map<String, dynamic> map}) {
    return TagModel(
      id: map['id'] as String? ?? map['name'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String? ?? '#FF0000',
      slug: map['slug'] as String? ?? '',
      bookIds: (map['bookIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'slug': slug,
      'bookIds': bookIds,
    };
  }

  /// Converts to entity.
  Tag toEntity() {
    return Tag(id: id, name: name, description: description, color: color);
  }

  /// Creates from entity, preserving [existingBookIds] if known.
  ///
  /// [existingBookIds] should be read from the database before calling this
  /// (e.g. during an update), so that the persisted book associations are not
  /// silently wiped. Defaults to an empty list for new records.
  factory TagModel.fromEntity(
    Tag tag, {
    List<String> existingBookIds = const [],
  }) {
    return TagModel(
      id: tag.id,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      slug: tag.slug,
      bookIds: existingBookIds,
    );
  }

  /// Returns a copy of this model with the given fields replaced.
  TagModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? slug,
    List<String>? bookIds,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      slug: slug ?? this.slug,
      bookIds: bookIds ?? this.bookIds,
    );
  }
}
