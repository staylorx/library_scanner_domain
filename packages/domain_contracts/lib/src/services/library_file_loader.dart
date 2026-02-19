import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for loading library files (e.g., YAML)
abstract class LibraryFileLoader {
  /// Loads YAML data from the specified file path
  TaskEither<Failure, dynamic> loadYaml(String filePath);
}