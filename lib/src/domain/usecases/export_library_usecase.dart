import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Use case for exporting a library to a file.
class ExportLibraryUsecase with Loggable {
  ExportLibraryUsecase({Logger? logger});

  /// Exports the library to the specified file path.
  Future<Either<Failure, Unit>> call({
    required String filePath,
    required Library library,
  }) async {
    logger?.info('ExportLibraryUsecase: Exporting library to $filePath');
    try {
      final yamlWriter = YamlWriter();
      // Build the data map, skipping null values
      final data = <String, dynamic>{};
      data['name'] = library.name;
      if (library.description != null) {
        data['description'] = library.description;
      }
      data['authors'] = library.authors.map((author) {
        final Map<String, dynamic> authorMap = {
          'name': author.name,
          'id_pairs': author.businessIds
              .map((id) => {'id_type': id.idType.name, 'id_code': id.idCode})
              .toList(),
        };
        if (author.biography != null) {
          authorMap['biography'] = author.biography;
        }
        return authorMap;
      }).toList();
      data['tags'] = library.tags
          .map((tag) => {'name': tag.name, 'color': tag.color})
          .toList();
      data['books'] = library.books.map((book) {
        final bookMap = <String, dynamic>{
          'title': book.title,
          'authors': book.authors.map((a) => {'name': a.name}).toList(),
          'tags': book.tags.isNotEmpty
              ? book.tags.map((t) => {'name': t.name}).toList()
              : null,
          'published_date': book.publishedDate?.toIso8601String(),
          'id_pairs': book.businessIds
              .map((id) => {'id_type': id.idType.name, 'id_code': id.idCode})
              .toList(),
        };
        return bookMap;
      }).toList();
      final yamlString = yamlWriter.write(data);
      final file = File(filePath);
      await file.writeAsString(yamlString);
      logger?.info('ExportLibraryUsecase: Successfully exported library');
      return Right(unit);
    } catch (e) {
      logger?.error('ExportLibraryUsecase: Failed to export library: $e');
      return Left(ServiceFailure('Failed to export library: $e'));
    }
  }
}
