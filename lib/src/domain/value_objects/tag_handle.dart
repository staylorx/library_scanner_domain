import 'package:uuid/uuid.dart';

/// Domain-opaque handle for Tag entities
class TagHandle {
  final String _value;

  const TagHandle(this._value);

  /// Factory for use cases to generate handles
  factory TagHandle.generate() => TagHandle(const Uuid().v4());

  /// Parse from string
  factory TagHandle.fromString(String value) => TagHandle(value);

  @override
  String toString() => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TagHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
