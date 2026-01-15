import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

// Top-level functions for parsing
/// Parses YAML data from a string.
Future<dynamic> parseYamlData(String yamlString) async => loadYaml(yamlString);

/// Parses authors from YAML data.
Future<Either<Failure, Map<String, Author>>> parseAuthors(
  dynamic yamlAuthors,
) async {
  return TaskEither.tryCatch(
    () async {
      final list = yamlAuthors as YamlList;
      final authors = <String, Author>{};
      for (final yamlAuthor in list) {
        final name = yamlAuthor['name'] as String;
        final idPairs = <AuthorIdPair>[];
        if (yamlAuthor['id_pairs'] != null) {
          final yamlIdPairs = yamlAuthor['id_pairs'] as List;
          for (final yamlId in yamlIdPairs) {
            final idType = AuthorIdType.values.firstWhere(
              (e) => e.name == yamlId['id_type'],
            );
            idPairs.add(
              AuthorIdPair(idType: idType, idCode: yamlId['id_code'] as String),
            );
          }
        }
        if (idPairs.isEmpty) {
          idPairs.add(AuthorIdPair(idType: AuthorIdType.local, idCode: name));
        }
        authors[name] = Author(
          businessIds: idPairs,
          name: name,
          biography: yamlAuthor['biography'] as String?,
        );
      }
      return authors;
    },
    (error, stackTrace) => ParsingFailure('Failed to parse authors: $error'),
  ).run();
}

/// Parses tags from YAML data.
Future<Either<Failure, List<Tag>>> parseTags(dynamic yamlTags) async {
  return TaskEither.tryCatch(
    () async {
      final list = yamlTags as YamlList;
      final tagMap = <String, Tag>{};
      for (final yamlTag in list) {
        final name = yamlTag['name'] as String;
        // Compute slug for uniqueness check
        final slug = computeSlug(name);
        // Skip if already exists (slug-based duplicate)
        if (!tagMap.containsKey(slug)) {
          tagMap[slug] = Tag(
            id: TagHandle.fromName(name),
            name: name,
            color: yamlTag['color'] as String,
          );
        }
      }
      return tagMap.values.toList();
    },
    (error, stackTrace) => ParsingFailure('Failed to parse tags: $error'),
  ).run();
}

/// Computes a slug from a string.
String computeSlug(String input) {
  var slug = input
      .toLowerCase()
      .replaceAll(
        RegExp(r'[^a-z0-9\s-]'),
        '',
      ) // Remove special chars except spaces and hyphens
      .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
      .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
      .trim();
  if (slug.startsWith('-')) slug = slug.substring(1);
  if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
  return slug;
}

/// Parameters for book parsing.
class BookParseParams {
  final dynamic yamlBooks;
  final Map<String, Author> authorMap;
  final List<Tag> tags;

  BookParseParams(this.yamlBooks, this.authorMap, this.tags);
}

/// Result of book parsing.
class BookParseResult {
  final List<Book> books;
  final List<String> errors;
  final List<String> missingAuthors;

  BookParseResult(this.books, this.errors, this.missingAuthors);
}

/// Parses books from YAML data with parameters.
Future<Either<Failure, BookParseResult>> parseBooks(
  BookParseParams params,
) async {
  return TaskEither.tryCatch(
    () async {
      final list = params.yamlBooks as YamlList;
      final books = <Book>[];
      final errors = <String>[];
      final missingAuthors = <String>{}; // Use set to avoid duplicates
      for (int i = 0; i < list.length; i++) {
        final yamlBook = list[i];
        try {
          final authorNames = (yamlBook['authors'] as List)
              .map((a) => a['name'] as String)
              .toList();
          final tagNames = yamlBook['tags'] != null
              ? (yamlBook['tags'] as List)
                    .map((t) => t['name'] as String)
                    .toList()
              : <String>[];
          final bookAuthors = <Author>[];
          for (final name in authorNames) {
            final author = params.authorMap[name];
            if (author != null) {
              bookAuthors.add(author);
            } else {
              missingAuthors.add(name);
            }
          }
          // Match tags by slug
          final tagSlugs = tagNames.map(computeSlug).toSet();
          final bookTags = params.tags
              .where((t) => tagSlugs.contains(t.slug))
              .toList();
          final idPairs = <BookIdPair>[];
          if (yamlBook['id_pairs'] != null) {
            final yamlIdPairs = yamlBook['id_pairs'] as List;
            for (final yamlId in yamlIdPairs) {
              final idType = BookIdType.values.firstWhere(
                (e) => e.name == yamlId['id_type'],
              );
              idPairs.add(
                BookIdPair(idType: idType, idCode: yamlId['id_code'] as String),
              );
            }
          }
          if (idPairs.isEmpty) {
            // Ensure every book has at least one local ID to prevent crashes
            // when accessing book.idPairs.first in BookListScreen.
            idPairs.add(
              BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
            );
          }
          final originalTitle = yamlBook['title'] as String;
          final publishedDate = yamlBook['published_date'] != null
              ? DateTime.parse(yamlBook['published_date'] as String)
              : null;
          books.add(
            Book(
              businessIds: idPairs,
              title: cleanBookTitle(title: originalTitle),
              originalTitle: originalTitle,
              authors: bookAuthors,
              tags: bookTags,
              publishedDate: publishedDate,
            ),
          );
        } catch (e) {
          errors.add('Failed to parse book at index ${i + 1}: $e');
        }
      }
      return BookParseResult(books, errors, missingAuthors.toList());
    },
    (error, stackTrace) => ParsingFailure('Failed to parse books: $error'),
  ).run();
}

/// Parameters for relationship updates.
class RelationshipUpdateParams {
  final List<Book> books;
  final List<Author> authors;
  final List<Tag> tags;

  RelationshipUpdateParams(this.books, this.authors, this.tags);
}

/// Parameters for book processing.
class BookProcessingParams {
  final List<RecordSnapshot<dynamic, dynamic>> bookRecords;
  final List<RecordSnapshot<dynamic, dynamic>> authorRecords;
  final List<RecordSnapshot<dynamic, dynamic>> tagRecords;

  BookProcessingParams(this.bookRecords, this.authorRecords, this.tagRecords);
}

/// Processes book records into entities.
Future<Either<Failure, List<Book>>> processBooks(
  BookProcessingParams params,
) async {
  return TaskEither.tryCatch(
    () async {
      final authorMap = <String, AuthorModel>{};
      for (final record in params.authorRecords) {
        try {
          authorMap[record.key as String] = AuthorModel.fromMap(
            map: record.value as Map<String, dynamic>,
          );
        } catch (e) {
          continue;
        }
      }

      final tagMap = <String, TagModel>{};
      for (final record in params.tagRecords) {
        try {
          tagMap[record.key.toString()] = TagModel.fromMap(
            map: record.value as Map<String, dynamic>,
          );
        } catch (e) {
          continue;
        }
      }

      final books = <Book>[];
      for (final record in params.bookRecords) {
        try {
          final model = BookModel.fromMap(
            map: record.value as Map<String, dynamic>,
          );
          final authors = model.authorIds
              .map((id) => authorMap[id])
              .whereType<AuthorModel>()
              .map((m) => m.toEntity())
              .toList();
          final tags = model.tagIds
              .map((id) => tagMap[id])
              .whereType<TagModel>()
              .map((m) => m.toEntity())
              .toList();
          books.add(model.toEntity(authors: authors, tags: tags));
        } catch (e) {
          continue;
        }
      }
      return books;
    },
    (error, stackTrace) => ParsingFailure('Failed to process books: $error'),
  ).run();
}

/// Updates relationships between entities.
Future<RelationshipUpdateParams> updateRelationships(
  RelationshipUpdateParams params,
) async {
  // Author books are not stored in entity anymore

  // Tag relationships are not stored in entity anymore

  return params; // Return updated params
}
