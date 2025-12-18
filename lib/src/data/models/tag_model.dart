import '../../domain/entities/tag.dart';

/// A data model representing a tag with its metadata.
class TagModel {
  /// The unique identifier for the tag, if assigned.
  final String? id;

  /// The name of the tag.
  final String name;

  /// The description of the tag.
  final String? description;

  /// The color associated with the tag.
  final String color;

  /// The list of book identifiers associated with the tag.
  final List<String> bookIdPairs;

  /// Creates a [TagModel] instance.
  const TagModel({
    this.id,
    required this.name,
    this.description,
    this.color = '#FF0000',

    /// Default red color
    required this.bookIdPairs,
  });

  /// Creates a [TagModel] from a map representation.
  factory TagModel.fromMap({required Map<String, dynamic> map}) {
    return TagModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String? ?? '#FF0000',
      bookIdPairs: (map['bookIdPairs'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts this [TagModel] to a map representation.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'color': color,
      'bookIdPairs': bookIdPairs,
    };
  }

  /// Converts this [TagModel] to a [Tag] domain entity.
  Tag toEntity() {
    return Tag(name: name, description: description, color: color);
  }

  /// Creates a [TagModel] from a [Tag] domain entity.
  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.name,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      bookIdPairs: [],

      /// New tags start with no books
    );
  }
}
