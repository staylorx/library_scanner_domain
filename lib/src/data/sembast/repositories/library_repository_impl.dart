import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:logging/logging.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

// Top-level functions for parsing
/// Parses YAML data from a string.
Future<dynamic> parseYamlData(String yamlString) async => loadYaml(yamlString);

/// Parses authors from YAML data.
Future<Map<String, Author>> parseAuthors(dynamic yamlAuthors) async {
  final list = yamlAuthors as YamlList;
  final authors = <String, Author>{};
  for (final yamlAuthor in list) {
    try {
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
    } catch (e) {
      rethrow;
    }
  }
  return authors;
}

/// Parses tags from YAML data.
Future<List<Tag>> parseTags(dynamic yamlTags) async {
  final list = yamlTags as YamlList;
  final tagMap = <String, Tag>{};
  for (final yamlTag in list) {
    try {
      final name = yamlTag['name'] as String;
      // Compute slug for uniqueness check
      final slug = _computeSlug(name);
      // Skip if already exists (slug-based duplicate)
      if (!tagMap.containsKey(slug)) {
        tagMap[slug] = Tag(
          id: TagHandle.fromName(name),
          name: name,
          color: yamlTag['color'] as String,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  return tagMap.values.toList();
}

/// Computes a slug from a string.
String _computeSlug(String input) {
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
Future<BookParseResult> parseBooks(BookParseParams params) async {
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
          ? (yamlBook['tags'] as List).map((t) => t['name'] as String).toList()
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
      final tagSlugs = tagNames.map(_computeSlug).toSet();
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
Future<List<Book>> processBooks(BookProcessingParams params) async {
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
}

/// Updates relationships between entities.
Future<RelationshipUpdateParams> updateRelationships(
  RelationshipUpdateParams params,
) async {
  // Author books are not stored in entity anymore

  // Tag relationships are not stored in entity anymore

  return params; // Return updated params
}

/// Implementation of library repository.
class LibraryRepositoryImpl implements LibraryRepository {
  final logger = Logger('LibraryRepositoryImpl');
  final SembastDatabase _database;
  final IsBookDuplicateUsecase _isBookDuplicateUsecase;

  LibraryRepositoryImpl({
    required DatabaseService database,
    required IsBookDuplicateUsecase isBookDuplicateUsecase,
  }) : _database = database as SembastDatabase,
       _isBookDuplicateUsecase = isBookDuplicateUsecase; // Initialize database

  /// Imports a library from a YAML file.
  @override
  Future<Either<Failure, ImportResult>> importLibrary(
    String filePath, {
    bool overwrite = false,
  }) async {
    logger.info(
      'Entering importLibrary with filePath: $filePath, overwrite: $overwrite',
    );
    try {
      final file = File(filePath);
      final yamlString = await file.readAsString();
      final yamlData = await parseYamlData(yamlString);
      logger.info('Parsed YAML data, keys: ${yamlData.keys}');
      logger.info(
        'authors present: ${yamlData.containsKey('authors')}, value: ${yamlData['authors']}',
      );
      logger.info(
        'tags present: ${yamlData.containsKey('tags')}, value: ${yamlData['tags']}',
      );
      logger.info(
        'books present: ${yamlData.containsKey('books')}, value: ${yamlData['books']}',
      );

      if (yamlData['books'] == null) {
        logger.severe('Books section is null or missing in YAML');
        return Left(
          ServiceFailure('Invalid YAML format: books section is required'),
        );
      }

      if (yamlData['tags'] == null) {
        logger.warning('Tags section is missing in YAML');
      }

      if (yamlData['authors'] == null) {
        logger.warning('Authors section is missing in YAML');
      }
      if (overwrite) {
        logger.info('Clearing existing data due to overwrite flag');
        final db = await _database.database;
        await _database.authorsStore.delete(db);
        await _database.booksStore.delete(db);
        await _database.tagsStore.delete(db);
        logger.info('Existing data cleared');
      }

      // Parse authors (optional, default empty)
      final authorMap = yamlData['authors'] != null
          ? await parseAuthors(yamlData['authors'])
          : <String, Author>{};
      final authors = authorMap.values.toList();
      logger.info('Parsed ${authors.length} authors');

      // Parse tags (optional, default empty)
      final tags = yamlData['tags'] != null
          ? await parseTags(yamlData['tags'])
          : <Tag>[];
      logger.info('Parsed ${tags.length} tags');

      // Collect all unique tagNames and authorNames from books
      final yamlBooks = yamlData['books'] as YamlList;
      final allBookTagNames = <String>{};
      final allBookAuthorNames = <String>{};
      for (final yamlBook in yamlBooks) {
        final tagNames = yamlBook['tags'] != null
            ? (yamlBook['tags'] as List).map((t) => t['name'] as String).toSet()
            : <String>{};
        allBookTagNames.addAll(tagNames);
        final authorNames = (yamlBook['authors'] as List)
            .map((a) => a['name'] as String)
            .toList();
        allBookAuthorNames.addAll(authorNames);
      }

      // Get existing tag slugs
      final existingTagSlugs = tags.map((t) => t.slug).toSet();

      // Find missing tags (by slug)
      final missingTagNames = allBookTagNames
          .where((name) => !existingTagSlugs.contains(_computeSlug(name)))
          .toSet();

      // Add missing tags
      for (final tagName in missingTagNames) {
        tags.add(
          Tag(id: TagHandle.fromName(tagName), name: tagName, color: "#808080"),
        );
      }

      // Find missing authors
      final existingAuthorNames = authorMap.keys.toSet();
      final missingAuthorNames = allBookAuthorNames.difference(
        existingAuthorNames,
      );

      // Add missing authors
      for (final authorName in missingAuthorNames) {
        final author = Author(
          businessIds: [
            AuthorIdPair(idType: AuthorIdType.local, idCode: authorName),
          ],
          name: authorName,
          biography: null,
        );
        authors.add(author);
        authorMap[authorName] = author;
      }
      final warnings = <String>[];
      if (missingAuthorNames.isNotEmpty) {
        logger.info(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
        warnings.add(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
      }

      // Parse books
      final bookParseParams = BookParseParams(
        yamlData['books'],
        authorMap,
        tags,
      );
      final bookResult = await parseBooks(bookParseParams);
      final parsedBooks = bookResult.books;
      logger.info('Parsed ${parsedBooks.length} books');
      if (bookResult.errors.isNotEmpty) {
        logger.warning('Parse errors encountered:');
        for (final error in bookResult.errors) {
          logger.warning(error);
        }
      }
      // Since we created missing authors, bookResult.missingAuthors should be empty now
      assert(bookResult.missingAuthors.isEmpty);

      // Filter out duplicates within parsed books and against existing if not overwrite
      final List<Book> books = [];
      final List<String> duplicateWarnings = [];

      // First, filter duplicates within parsed books
      for (final book in parsedBooks) {
        final isDuplicateInParsed = books.any(
          (existing) => _isBookDuplicateUsecase
              .call(bookA: book, bookB: existing)
              .getRight()
              .getOrElse(() => false),
        );
        if (!isDuplicateInParsed) {
          books.add(book);
        } else {
          duplicateWarnings.add(
            'Skipped duplicate book in import: ${book.title}',
          );
        }
      }

      // If not overwrite, check against existing books
      if (!overwrite) {
        final db = await _database.database;
        final bookRecords = await _database.booksStore.find(db);
        final authorRecords = await _database.authorsStore.find(db);
        final tagRecords = await _database.tagsStore.find(db);
        final processingParams = BookProcessingParams(
          bookRecords,
          authorRecords,
          tagRecords,
        );
        final existingBooks = await processBooks(processingParams);
        final List<Book> finalBooks = [];
        for (final book in books) {
          final isDuplicateExisting = existingBooks.any(
            (existing) => _isBookDuplicateUsecase
                .call(bookA: book, bookB: existing)
                .getRight()
                .getOrElse(() => false),
          );
          if (!isDuplicateExisting) {
            finalBooks.add(book);
          } else {
            duplicateWarnings.add(
              'Skipped existing duplicate book in import: ${book.title}',
            );
          }
        }
        books.clear();
        books.addAll(finalBooks);
      }

      if (duplicateWarnings.isNotEmpty) {
        warnings.addAll(duplicateWarnings);
      }

      // Update relationships
      final relationshipParams = RelationshipUpdateParams(books, authors, tags);
      await updateRelationships(relationshipParams);
      logger.info('Updated relationships');

      final db = await _database.database;
      logger.info('Starting database write operations...');

      // Use transaction for batch operations
      await db.transaction((txn) async {
        // Save authors
        for (final author in authors) {
          final authorModel = AuthorModel.fromEntity(author, author.name);
          await _database.authorsStore
              .record(author.name)
              .put(txn, authorModel.toMap());
        }
        logger.info('Saved ${authors.length} authors to database');

        // Save tags
        for (final tag in tags) {
          final tagModel = TagModel.fromEntity(tag);
          await _database.tagsStore.record(tag.name).put(txn, tagModel.toMap());
        }
        logger.info('Saved ${tags.length} tags to database');

        // Save books
        for (final book in books) {
          final bookKey = const Uuid().v4();
          final bookModel = BookModel.fromEntity(book, bookKey);
          await _database.booksStore
              .record(bookKey)
              .put(txn, bookModel.toMap());
        }
        logger.info('Saved ${books.length} books to database');
      });
      logger.info('Committed all database operations in transaction');

      final library = Library(
        name: yamlData['name'] as String? ?? 'Imported Library',
        description:
            yamlData['description'] as String? ?? 'Imported from $filePath',
        books: books,
        authors: authors,
        tags: tags,
      );

      final importResult = ImportResult(
        library: library,
        parseErrors: bookResult.errors,
        warnings: warnings,
      );

      logger.info('Successfully imported library');
      return Right(importResult);
    } catch (e) {
      logger.severe('Failed to import library: $e');
      return Left(ServiceFailure('Failed to import library: $e'));
    }
  }

  /// Exports a library to a YAML file.
  @override
  Future<Either<Failure, Unit>> exportLibrary({
    required String filePath,
    required Library library,
  }) async {
    logger.info('Entering exportLibrary with filePath: $filePath');
    try {
      final yamlWriter = YamlWriter();
      // Build the data map, skipping null values
      final data = <String, dynamic>{};
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
          'authorNames': book.authors.map((a) => a.name).toList(),
          'tagNames': book.tags.map((t) => t.name).toList(),
        };
        if (book.publishedDate != null) {
          bookMap['year'] = book.publishedDate!.year;
        }
        final isbnIds = book.businessIds.where(
          (id) => id.idType == BookIdType.isbn,
        );
        if (isbnIds.isNotEmpty) {
          bookMap['isbn'] = isbnIds.first.idCode;
        }
        return bookMap;
      }).toList();
      final yamlString = yamlWriter.write(data);
      final file = File(filePath);
      await file.writeAsString(yamlString);
      logger.info('Successfully exported library to $filePath');
      return Right(unit);
    } catch (e) {
      logger.severe('Failed to export library: $e');
      return Left(ServiceFailure('Failed to export library: $e'));
    }
  }

  /// Clears all data from the library.
  @override
  Future<Either<Failure, Unit>> clearLibrary() async {
    logger.info('Entering clearLibrary');
    try {
      final db = await _database.database;
      await db.transaction((txn) async {
        await _database.authorsStore.delete(txn);
        await _database.booksStore.delete(txn);
        await _database.tagsStore.delete(txn);
      });
      logger.info('Successfully cleared library');
      return Right(unit);
    } catch (e) {
      logger.severe('Failed to clear library: $e');
      return Left(ServiceFailure('Failed to clear library: $e'));
    }
  }
}
