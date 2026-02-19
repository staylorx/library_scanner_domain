import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Use case for exporting a library to a file.
class ExportLibraryUsecase with Loggable {
  final LibraryDataAccess dataAccess;
  final LibraryFileWriter fileWriter;

  ExportLibraryUsecase({
    Logger? logger,
    required this.dataAccess,
    required this.fileWriter,
  }) {
    this.logger = logger;
  }

  /// Exports the current library to the specified file path.
  TaskEither<Failure, Unit> call({required String filePath}) {
    logger?.info('ExportLibraryUsecase: Exporting library to $filePath');
    return dataAccess.bookRepository.getBooks().flatMap((books) {
      return dataAccess.authorRepository.getAll().flatMap((authors) {
        return dataAccess.tagRepository.getAll().flatMap((tags) {
          final library = Library(
            name: 'Exported Library',
            description: 'Current library exported on ${DateTime.now()}',
            books: books,
            authors: authors,
            tags: tags,
          );
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
                  .map(
                    (id) => {'id_type': id.idType.name, 'id_code': id.idCode},
                  )
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
                  .map(
                    (id) => {'id_type': id.idType.name, 'id_code': id.idCode},
                  )
                  .toList(),
            };
            return bookMap;
          }).toList();
          final yamlString = yamlWriter.write(data);

          return fileWriter
              .writeYaml(filePath, yamlString)
              .map((_) {
                logger?.info(
                  'ExportLibraryUsecase: Successfully exported library',
                );
                return unit;
              })
              .mapLeft((failure) {
                logger?.error(
                  'ExportLibraryUsecase: Failed to export library: $failure',
                );
                return ServiceFailure('Failed to export library: $failure');
              });
        });
      });
    });
  }
}
