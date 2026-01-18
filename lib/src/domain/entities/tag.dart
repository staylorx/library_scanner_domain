import 'package:equatable/equatable.dart';
import '../utils/slug_utils.dart';

/// Represents a tag.
class Tag with EquatableMixin {
  /// Entity identifier.
  final String id;

  /// Tag name.
  final String name;

  /// Tag description.
  final String? description;

  /// Tag color.
  final String color;

  /// Slug version of the name.
  String get slug => computeSlug(name);

  /// Creates Tag.
  Tag({
    required this.id,
    required this.name,
    this.description,
    this.color = '#FF0000',

    /// Default red color
  });

  /// Creates a copy with optional updates.
  Tag copyWith({String? id, String? name, String? description, String? color}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, name, description, color];
}
