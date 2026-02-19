import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for writing library files (e.g., YAML)
abstract class LibraryFileWriter {
  /// Writes YAML data to the specified file path
  TaskEither<Failure, Unit> writeYaml(String filePath, String yamlContent);
}