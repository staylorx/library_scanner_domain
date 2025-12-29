import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// A domain entity representing a tag.
class Tag with EquatableMixin {
  /// The unique identifier for the tag.
  final String id;

  /// The name of the tag, stored in lowercase.
  final String _name;

  /// The name of the tag.
  String get name => _name;

  /// The description of the tag.
  final String? description;

  /// The color associated with the tag.
  final String color;

  /// The slug version of the name for URL-friendly use.
  String get slug => _sluggify(_name);

  /// Creates a [Tag] instance.
  Tag({
    String? id,
    required String name,
    this.description,
    this.color = '#FF0000',

    /// Default red color
  }) : id = id ?? const Uuid().v4(),
       _name = name.toLowerCase();

  /// Creates a copy of this [Tag] with optional field updates.
  Tag copyWith({String? id, String? name, String? description, String? color}) {
    return Tag(
      id: id ?? this.id,
      name: name != null ? name.toLowerCase() : this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  /// Converts a string to a slug format.
  String _sluggify(String input) {
    var slug = input
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9\s-]'),
          '',
        ) // Remove special chars except spaces and hyphens
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .trim();
    if (slug.startsWith('-')) slug = slug.substring(1);
    if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
    return slug;
  }

  @override
  List<Object?> get props => [id, name, description, color];
}
