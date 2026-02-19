import 'package:library_scanner_domain/library_scanner_domain.dart';

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

  /// Creates from entity.
  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.id,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      slug: tag.slug,
      bookIds: [],
    );
  }
}
