import 'package:equatable/equatable.dart';

/// A domain entity representing a tag.
class Tag with EquatableMixin {
  /// The name of the tag, stored in lowercase.
  final String _name;
  /// The name of the tag.
  String get name => _name;
  /// The description of the tag.
  final String? description;
  /// The color associated with the tag.
  final String color;

  /// Creates a [Tag] instance.
  Tag({
    required String name,
    this.description,
    this.color = '#FF0000', /// Default red color
  }) : _name = name.toLowerCase();

  /// Creates a copy of this [Tag] with optional field updates.
  Tag copyWith({String? name, String? description, String? color}) {
    return Tag(
      name: name != null ? name.toLowerCase() : this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [name, description, color];
}
