import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Infrastructure implementation of [LibraryFileWriter] using dart:io.
class LibraryFileWriterImpl implements LibraryFileWriter {
  @override
  TaskEither<Failure, Unit> writeYaml(String filePath, String contents) {
    return TaskEither.tryCatch(() async {
      final file = File(filePath);
      await file.writeAsString(contents);
      return unit;
    }, (error, stack) => ServiceFailure('Failed to write YAML file: $error'));
  }
}
