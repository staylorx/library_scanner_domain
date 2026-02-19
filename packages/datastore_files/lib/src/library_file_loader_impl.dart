import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
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