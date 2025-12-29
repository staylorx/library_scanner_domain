import "library.dart";
import 'package:equatable/equatable.dart';

/// Result of importing a library.
class ImportResult with EquatableMixin {
  /// The imported library.
  final Library library;

  /// List of parse errors encountered.
  final List<String> parseErrors;

  /// List of warnings encountered.
  final List<String> warnings;

  /// Creates an ImportResult instance.
  const ImportResult({
    required this.library,
    required this.parseErrors,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [library, parseErrors, warnings];
}
