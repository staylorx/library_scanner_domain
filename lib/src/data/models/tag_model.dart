import '../../domain/entities/tag.dart';

class TagModel {
  final String? id;
  final String name;
  final String? description;
  final String color;
  final List<String> bookIds;

  const TagModel({
    this.id,
    required this.name,
    this.description,
    this.color = '#FF0000', // Default red color
    required this.bookIds,
  });

  factory TagModel.fromMap({required Map<String, dynamic> map}) {
    return TagModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String? ?? '#FF0000',
      bookIds: (map['bookIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'color': color,
      'bookIds': bookIds,
    };
  }

  Tag toEntity() {
    return Tag(name: name, description: description, color: color);
  }

  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.name,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      bookIds: [], // New tags start with no books
    );
  }
}
