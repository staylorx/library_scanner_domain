import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Port for writing a library YAML file. Infrastructure should implement this.
abstract class LibraryFileWriter {
  /// Writes YAML [contents] to [filePath].
  TaskEither<Failure, Unit> writeYaml(String filePath, String contents);
}
