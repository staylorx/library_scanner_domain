import 'package:uuid/uuid.dart';

/// Domain-opaque handle for Book entities
class BookHandle {
  final String _value;

  const BookHandle(this._value);

  /// Factory for use cases to generate handles
  factory BookHandle.generate() => BookHandle(const Uuid().v4());

  /// Parse from string
  factory BookHandle.fromString(String value) => BookHandle(value);

  @override
  String toString() => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
