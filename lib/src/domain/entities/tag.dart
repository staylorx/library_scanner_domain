import 'package:equatable/equatable.dart';

class Tag with EquatableMixin {
  final String _name;
  String get name => _name;
  final String? description;
  final String color;

  Tag({
    required String name,
    this.description,
    this.color = '#FF0000', // Default red color
  }) : _name = name.toLowerCase();

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
