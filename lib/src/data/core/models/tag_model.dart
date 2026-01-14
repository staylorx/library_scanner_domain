import '../../../domain/entities/tag.dart';
import '../../../domain/value_objects/tag_handle.dart';

/// A data model representing a tag with its metadata.
class TagModel {
  /// The unique identifier for the tag (same as name).
  final String id;

  /// The name of the tag.
  final String name;

  /// The description of the tag.
  final String? description;

  /// The color associated with the tag.
  final String color;

  /// The slug version of the name for uniqueness.
  final String slug;

  /// The list of book identifiers associated with the tag.
  final List<String> bookIdPairs;

  /// Creates a [TagModel] instance.
  const TagModel({
    required this.id,
    required this.name,
    this.description,
    this.color = '#FF0000',

    /// Default red color
    required this.slug,
    required this.bookIdPairs,
  });

  /// Creates a [TagModel] from a map representation.
  factory TagModel.fromMap({required Map<String, dynamic> map}) {
    return TagModel(
      id: map['id'] as String? ?? map['name'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String? ?? '#FF0000',
      slug: map['slug'] as String? ?? '',
      bookIdPairs: (map['bookIdPairs'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts this [TagModel] to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': name,
      'name': name,
      'description': description,
      'color': color,
      'slug': slug,
      'bookIdPairs': bookIdPairs,
    };
  }

  /// Converts this [TagModel] to a [Tag] domain entity.
  Tag toEntity() {
    return Tag(
      id: TagHandle(id),
      name: name,
      description: description,
      color: color,
    );
  }

  /// Creates a [TagModel] from a [Tag] domain entity.
  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.name,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      slug: tag.slug,
      bookIdPairs: [],

      /// New tags start with no books
    );
  }
}
