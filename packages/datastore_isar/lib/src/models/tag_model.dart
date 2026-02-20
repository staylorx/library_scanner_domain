import 'package:domain_entities/domain_entities.dart';

/// Data model for a tag.
class TagModel {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String slug;
  final List<String> bookIds;

  const TagModel({
    required this.id,
    required this.name,
    this.description,
    this.color = '#FF0000',
    required this.slug,
    required this.bookIds,
  });

  factory TagModel.fromMap({required Map<String, dynamic> map}) => TagModel(
    id: map['id'] as String? ?? map['name'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
    color: map['color'] as String? ?? '#FF0000',
    slug: map['slug'] as String? ?? '',
    bookIds: (map['bookIds'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'slug': slug,
    'bookIds': bookIds,
  };

  Tag toEntity() =>
      Tag(id: id, name: name, description: description, color: color);

  factory TagModel.fromEntity(
    Tag tag, {
    List<String> existingBookIds = const [],
  }) => TagModel(
    id: tag.id,
    name: tag.name,
    description: tag.description,
    color: tag.color,
    slug: tag.slug,
    bookIds: existingBookIds,
  );

  TagModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? slug,
    List<String>? bookIds,
  }) => TagModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    color: color ?? this.color,
    slug: slug ?? this.slug,
    bookIds: bookIds ?? this.bookIds,
  );
}
