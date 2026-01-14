import 'package:uuid/uuid.dart';

/// Domain-opaque handle for Author entities
class AuthorHandle {
  final String _value;

  const AuthorHandle(this._value);

  /// Factory for use cases to generate handles
  factory AuthorHandle.generate() => AuthorHandle(const Uuid().v4());

  /// Parse from string
  factory AuthorHandle.fromString(String value) => AuthorHandle(value);

  @override
  String toString() => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthorHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
