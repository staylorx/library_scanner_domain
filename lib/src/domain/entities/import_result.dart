import "library.dart";
import 'package:equatable/equatable.dart';

class ImportResult with EquatableMixin {
  final Library library;
  final List<String> parseErrors;
  final List<String> warnings;

  const ImportResult({
    required this.library,
    required this.parseErrors,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [library, parseErrors, warnings];
}
