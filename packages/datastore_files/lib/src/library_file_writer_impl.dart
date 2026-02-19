import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';

/// Infrastructure implementation of [LibraryFileWriter] using dart:io.
class LibraryFileWriterImpl implements LibraryFileWriter {
  @override
  TaskEither<Failure, Unit> writeYaml(String filePath, String yamlContent) {
    return TaskEither.tryCatch(() async {
      final file = File(filePath);
      await file.writeAsString(yamlContent);
      return unit;
    }, (error, stack) => ServiceFailure('Failed to write YAML file: $error'));
  }
}