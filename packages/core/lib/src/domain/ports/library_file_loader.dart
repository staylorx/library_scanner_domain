import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Port for loading a library YAML file. Infrastructure should implement this.
abstract class LibraryFileLoader {
  /// Loads and parses YAML from [filePath] and returns the parsed structure.
  TaskEither<Failure, dynamic> loadYaml(String filePath);
}
