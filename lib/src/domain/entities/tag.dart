import 'package:equatable/equatable.dart';

/// Represents a tag.
class Tag with EquatableMixin {
  /// Tag name.
  final String name;

  /// Tag description.
  final String? description;

  /// Tag color.
  final String color;

  /// Slug version of the name.
  String get slug => _sluggify(name);

  /// Creates Tag.
  Tag({
    required this.name,
    this.description,
    this.color = '#FF0000',

    /// Default red color
  });

  /// Creates a copy with optional updates.
  Tag copyWith({String? name, String? description, String? color}) {
    return Tag(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  /// Converts string to slug.
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
  List<Object?> get props => [name, description, color];
}
