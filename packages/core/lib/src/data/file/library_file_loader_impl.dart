import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:yaml/yaml.dart' as yaml;

/// Infrastructure implementation of [LibraryFileLoader] using dart:io.
class LibraryFileLoaderImpl implements LibraryFileLoader {
  @override
  TaskEither<Failure, dynamic> loadYaml(String filePath) {
    return TaskEither.tryCatch(() async {
      final file = File(filePath);
      final yamlString = await file.readAsString();
      return yaml.loadYaml(yamlString);
    }, (error, stack) => ServiceFailure('Failed to read YAML file: $error'));
  }
}
