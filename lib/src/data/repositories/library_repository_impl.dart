import 'dart:io';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import 'package:uuid/uuid.dart';

// TODO: these aren't isolates anymore. Leave that to the presentation layer if needed?

// Top-level functions for parsing in background isolates
Future<dynamic> parseYamlData(String yamlString) async => loadYaml(yamlString);

// Parse authors in isolate
Future<Map<String, Author>> parseAuthorsIsolate(dynamic yamlAuthors) async {
  final list = yamlAuthors as YamlList;
  final authors = <String, Author>{};
  for (final yamlAuthor in list) {
    try {
      final name =
          '${yamlAuthor['firstName'] as String} ${yamlAuthor['lastName'] as String}';
      authors[name] = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: name),
        ]),
        name: name,
        biography: yamlAuthor['Biography'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }
  return authors;
}

// Parse tags in isolate
Future<List<Tag>> parseTagsIsolate(dynamic yamlTags) async {
  final list = yamlTags as YamlList;
  final tagMap = <String, Tag>{};
  for (final yamlTag in list) {
    try {
      final name = (yamlTag['name'] as String).toLowerCase();
      // Skip if already exists (case-insensitive duplicate)
      if (!tagMap.containsKey(name)) {
        tagMap[name] = Tag(name: name, color: yamlTag['color'] as String);
      }
    } catch (e) {
      rethrow;
    }
  }
  return tagMap.values.toList();
}

// Data class for book parsing parameters
class BookParseParams {
  final dynamic yamlBooks;
  final Map<String, Author> authorMap;
  final List<Tag> tags;

  BookParseParams(this.yamlBooks, this.authorMap, this.tags);
}

// Data class for book parsing result
class BookParseResult {
  final List<Book> books;
  final List<String> errors;
  final List<String> missingAuthors;

  BookParseResult(this.books, this.errors, this.missingAuthors);
}

// Parse books in isolate
Future<BookParseResult> parseBooksIsolate(BookParseParams params) async {
  final list = params.yamlBooks as YamlList;
  final books = <Book>[];
  final errors = <String>[];
  final missingAuthors = <String>{}; // Use set to avoid duplicates
  for (int i = 0; i < list.length; i++) {
    final yamlBook = list[i];
    try {
      final authorNames = List<String>.from(yamlBook['authorNames'] as List);
      final tagNames = yamlBook['tagNames'] != null
          ? List<String>.from(
              yamlBook['tagNames'] as List,
            ).map((name) => name.toLowerCase()).toList()
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
      final bookTags = params.tags
          .where((t) => tagNames.contains(t.name))
          .toList();
      final isbnRaw = yamlBook['isbn'];
      final idPairs = <BookIdPair>[];
      if (isbnRaw != null) {
        String isbn = isbnRaw is int ? isbnRaw.toString() : isbnRaw as String;
        // Normalize
        if (isbn.length == 9) {
          isbn = '0$isbn';
        } else if (isbn.length == 12) {
          isbn = '0$isbn';
        } else if (isbn.length == 10 || isbn.length == 13) {
          // fine
        } else {
          // invalid, add local
          idPairs.add(
            BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
          );
          books.add(
            Book(
              title: yamlBook['title'] as String,
              authors: bookAuthors,
              tags: bookTags,
              publishedDate: yamlBook['year'] != null
                  ? DateTime(yamlBook['year'] as int, 1, 1)
                  : null,
              idPairs: IdPairSet(idPairs),
            ),
          );
          continue;
        }
        BookIdType bookIdType;
        if (isbn.length == 10) {
          bookIdType = BookIdType.isbn;
        } else if (isbn.length == 13) {
          bookIdType = BookIdType.isbn13;
        } else {
          // shouldn't happen
          idPairs.add(
            BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
          );
          books.add(
            Book(
              title: yamlBook['title'] as String,
              authors: bookAuthors,
              tags: bookTags,
              publishedDate: yamlBook['year'] != null
                  ? DateTime(yamlBook['year'] as int, 1, 1)
                  : null,
              idPairs: IdPairSet(idPairs),
            ),
          );
          continue;
        }
        idPairs.add(BookIdPair(idType: bookIdType, idCode: isbn));
      } else {
        // Ensure every book has at least one local ID to prevent crashes
        // when accessing book.idPairs.first in BookListScreen.
        idPairs.add(
          BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
        );
      }
      books.add(
        Book(
          title: yamlBook['title'] as String,
          authors: bookAuthors,
          tags: bookTags,
          publishedDate: yamlBook['year'] != null
              ? DateTime(yamlBook['year'] as int, 1, 1)
              : null,
          idPairs: IdPairSet(idPairs),
        ),
      );
    } catch (e) {
      errors.add('Failed to parse book at index ${i + 1}: $e');
    }
  }
  return BookParseResult(books, errors, missingAuthors.toList());
}

// Data class for relationship update parameters
class RelationshipUpdateParams {
  final List<Book> books;
  final List<Author> authors;
  final List<Tag> tags;

  RelationshipUpdateParams(this.books, this.authors, this.tags);
}

// Data class for book processing parameters
class BookProcessingParams {
  final List<RecordSnapshot<dynamic, dynamic>> bookRecords;
  final List<RecordSnapshot<dynamic, dynamic>> authorRecords;
  final List<RecordSnapshot<dynamic, dynamic>> tagRecords;

  BookProcessingParams(this.bookRecords, this.authorRecords, this.tagRecords);
}

// Process books in isolate
Future<List<Book>> processBooksIsolate(BookProcessingParams params) async {
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

// Update relationships in isolate
Future<RelationshipUpdateParams> updateRelationshipsIsolate(
  RelationshipUpdateParams params,
) async {
  // Author books are not stored in entity anymore

  // Tag relationships are not stored in entity anymore

  return params; // Return updated params
}

@Injectable(as: ILibraryRepository)
@lazySingleton
class LibraryRepositoryImpl implements ILibraryRepository {
  final logger = DevLogger('LibraryRepositoryImpl');
  final DatabaseService _databaseService;
  final IsBookDuplicateUsecase _isBookDuplicateUsecase;

  LibraryRepositoryImpl({
    required DatabaseService databaseService,
    required IsBookDuplicateUsecase isBookDuplicateUsecase,
  }) : _databaseService = databaseService,
       _isBookDuplicateUsecase = isBookDuplicateUsecase; // Initialize database

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
        logger.error('Books section is null or missing in YAML');
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

      // Parse authors in isolate (optional, default empty)
      final authorMap = yamlData['authors'] != null
          ? await parseAuthorsIsolate(yamlData['authors'])
          : <String, Author>{};
      final authors = authorMap.values.toList();
      logger.info('Parsed ${authors.length} authors');

      // Parse tags in isolate (optional, default empty)
      final tags = yamlData['tags'] != null
          ? await parseTagsIsolate(yamlData['tags'])
          : <Tag>[];
      logger.info('Parsed ${tags.length} tags');

      // Collect all unique tagNames and authorNames from books
      final yamlBooks = yamlData['books'] as YamlList;
      final allBookTagNames = <String>{};
      final allBookAuthorNames = <String>{};
      for (final yamlBook in yamlBooks) {
        final tagNames = yamlBook['tagNames'] != null
            ? List<String>.from(
                yamlBook['tagNames'] as List,
              ).map((name) => name.toLowerCase()).toSet()
            : <String>{};
        allBookTagNames.addAll(tagNames);
        final authorNames = List<String>.from(yamlBook['authorNames'] as List);
        allBookAuthorNames.addAll(authorNames);
      }

      // Get existing tag names
      final existingTagNames = tags.map((t) => t.name).toSet();

      // Find missing tags
      final missingTagNames = allBookTagNames.difference(existingTagNames);

      // Add missing tags
      for (final tagName in missingTagNames) {
        tags.add(Tag(name: tagName, color: "#808080"));
      }

      // Find missing authors
      final existingAuthorNames = authorMap.keys.toSet();
      final missingAuthorNames = allBookAuthorNames.difference(
        existingAuthorNames,
      );

      // Add missing authors
      // TODO: Enhance this to parse first and last names if possible
      for (final authorName in missingAuthorNames) {
        final author = Author(
          idPairs: IdPairSet([
            AuthorIdPair(idType: AuthorIdType.local, idCode: authorName),
          ]),
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

      // Parse books in isolate
      final bookParseParams = BookParseParams(
        yamlData['books'],
        authorMap,
        tags,
      );
      final bookResult = await parseBooksIsolate(bookParseParams);
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
        final existingBooks = await processBooksIsolate(processingParams);
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

      // Update relationships in isolate
      final relationshipParams = RelationshipUpdateParams(books, authors, tags);
      await updateRelationshipsIsolate(relationshipParams);
      logger.info('Updated relationships');

      final db = await _database.database;
      logger.info('Starting database write operations...');

      // Use transaction for batch operations
      await db.transaction((txn) async {
        // Save authors
        for (final author in authors) {
          final authorModel = AuthorModel.fromEntity(author);
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
          final bookKey = book.key;
          final bookModel = BookModel.fromEntity(book: book);
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
      logger.error('Failed to import library: $e');
      return Left(ServiceFailure('Failed to import library: $e'));
    }
  }

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
        final names = author.name.split(' ');
        final Map<String, dynamic> authorMap = {
          'firstName': names.first,
          'lastName': names.length > 1 ? names.sublist(1).join(' ') : '',
        };
        if (author.biography != null) {
          authorMap['Biography'] = author.biography;
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
        final isbnIds = book.idPairs.idPairs.where(
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
      logger.error('Failed to export library: $e');
      return Left(ServiceFailure('Failed to export library: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearLibrary() async {
    logger.info('Entering clearLibrary');
    try {
      final result = await _databaseService.clearAll();
      return result.fold(
        (failure) => Left(failure),
        (_) {
          logger.info('Successfully cleared library');
          return Right(unit);
        },
      );
    } catch (e) {
      logger.error('Failed to clear library: $e');
      return Left(ServiceFailure('Failed to clear library: $e'));
    }
  }
}
