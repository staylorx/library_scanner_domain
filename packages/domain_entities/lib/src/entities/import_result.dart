import "library.dart";
import 'package:equatable/equatable.dart';

/// Import result.
class ImportResult with EquatableMixin {
  /// Imported library.
  final Library library;

  /// Parse errors.
  final List<String> parseErrors;

  /// Warnings.
  final List<String> warnings;

  /// Creates ImportResult.
  const ImportResult({
    required this.library,
    required this.parseErrors,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [library, parseErrors, warnings];
}
