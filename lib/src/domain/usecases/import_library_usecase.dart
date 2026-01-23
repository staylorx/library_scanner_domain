import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:slugify_string/slugify_string.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

class _BookParseParams {
  final dynamic yamlBooks;
  final Map<String, Author> authorMap;
  final List<Tag> tags;

  _BookParseParams(this.yamlBooks, this.authorMap, this.tags);
}

class _BookParseResult {
  final List<Book> books;
  final List<String> errors;
  final List<String> missingAuthors;

  _BookParseResult(this.books, this.errors, this.missingAuthors);
}

/// Use case for importing a library from a file.
class ImportLibraryUsecase with Loggable {
  final LibraryDataAccess dataAccess;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;

  ImportLibraryUsecase({
    Logger? logger,
    required this.dataAccess,
    required this.isBookDuplicateUsecase,
  });

  /// Parses authors from YAML data.
  Future<Either<Failure, Map<String, Author>>> _parseAuthors(
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
                AuthorIdPair(
                  idType: idType,
                  idCode: yamlId['id_code'] as String,
                ),
              );
            }
          }
          if (idPairs.isEmpty) {
            idPairs.add(
              AuthorIdPair(
                idType: AuthorIdType.local,
                idCode: Slugify(name).toString(),
              ),
            );
          }
          authors[name] = Author(
            id: const Uuid().v4(),
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
  Future<Either<Failure, List<Tag>>> _parseTags(dynamic yamlTags) async {
    return TaskEither.tryCatch(
      () async {
        final list = yamlTags as YamlList;
        final tagMap = <String, Tag>{};
        for (final yamlTag in list) {
          final name = yamlTag['name'] as String;
          // Compute slug for uniqueness check
          final slug = Slugify(name).toString();
          // Skip if already exists (slug-based duplicate)
          if (!tagMap.containsKey(slug)) {
            tagMap[slug] = Tag(
              id: const Uuid().v4(),
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

  /// Parses books from YAML data with parameters.
  Future<Either<Failure, _BookParseResult>> _parseBooks(
    _BookParseParams params,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final list = params.yamlBooks as YamlList;
        final books = <Book>[];
        final errors = <String>[];
        final missingAuthors = <String>{}; // Use set to avoid duplicates
        for (int i = 0; i < list.length; i++) {
          final yamlBook = list[i];
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
          final tagSlugs = tagNames
              .map((name) => Slugify(name).toString())
              .toSet();
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
              id: const Uuid().v4(),
              businessIds: idPairs,
              title: cleanBookTitle(title: originalTitle),
              originalTitle: originalTitle,
              authors: bookAuthors,
              tags: bookTags,
              publishedDate: publishedDate,
            ),
          );
        }
        return _BookParseResult(books, errors, missingAuthors.toList());
      },
      (error, stackTrace) => ParsingFailure('Failed to parse books: $error'),
    ).run();
  }

  /// Imports a library from the specified file path.
  Future<Either<Failure, ImportResult>> call({
    required String filePath,
    bool overwrite = false,
  }) async {
    logger?.info(
      'ImportLibraryUsecase: Importing library from $filePath, overwrite: $overwrite',
    );
    try {
      final file = File(filePath);
      final yamlString = await file.readAsString();
      final yamlData = loadYaml(yamlString);
      logger?.info('Parsed YAML data, keys: ${yamlData.keys}');
      logger?.info(
        'authors present: ${yamlData.containsKey('authors')}, value: ${yamlData['authors']}',
      );
      logger?.info(
        'tags present: ${yamlData.containsKey('tags')}, value: ${yamlData['tags']}',
      );
      logger?.info(
        'books present: ${yamlData.containsKey('books')}, value: ${yamlData['books']}',
      );

      if (yamlData['books'] == null) {
        logger?.error('Books section is null or missing in YAML');
        return Left(
          ServiceFailure('Invalid YAML format: books section is required'),
        );
      }

      if (yamlData['tags'] == null) {
        logger?.warning('Tags section is missing in YAML');
      }

      if (yamlData['authors'] == null) {
        logger?.warning('Authors section is missing in YAML');
      }
      if (overwrite) {
        logger?.info('Clearing existing data due to overwrite flag');
        final clearResult = await dataAccess.databaseService.clearAll();
        if (clearResult.isLeft()) {
          return Left(
            clearResult.getLeft().getOrElse(
              () => ServiceFailure('Clear failed'),
            ),
          );
        }
        logger?.info('Existing data cleared');
      }

      // Parse authors (optional, default empty)
      final Either<Failure, Map<String, Author>> authorMapEither =
          yamlData['authors'] != null
          ? await _parseAuthors(yamlData['authors'])
          : Right(<String, Author>{});
      final authorMap = authorMapEither.match(
        (failure) => throw ServiceFailure(
          'Parse error',
        ), // Let the outer try-catch handle it
        (map) => map,
      );
      final authors = authorMap.values.toList();
      logger?.info('Parsed ${authors.length} authors');

      // Parse tags (optional, default empty)
      final Either<Failure, List<Tag>> tagsEither = yamlData['tags'] != null
          ? await _parseTags(yamlData['tags'])
          : Right(<Tag>[]);
      final tags = tagsEither.match(
        (failure) => throw ServiceFailure('Parse error'),
        (list) => list,
      );
      logger?.info('Parsed ${tags.length} tags');

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
          .where((name) => !existingTagSlugs.contains(Slugify(name).toString()))
          .toSet();

      // Add missing tags
      for (final tagName in missingTagNames) {
        tags.add(Tag(id: const Uuid().v4(), name: tagName, color: "#808080"));
      }

      // Find missing authors
      final existingAuthorNames = authorMap.keys.toSet();
      final missingAuthorNames = allBookAuthorNames.difference(
        existingAuthorNames,
      );

      // Add missing authors
      for (final authorName in missingAuthorNames) {
        final author = Author(
          id: const Uuid().v4(),
          businessIds: [
            AuthorIdPair(
              idType: AuthorIdType.local,
              idCode: Slugify(authorName).toString(),
            ),
          ],
          name: authorName,
          biography: null,
        );
        authors.add(author);
        authorMap[authorName] = author;
      }
      final warnings = <String>[];
      if (missingAuthorNames.isNotEmpty) {
        logger?.info(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
        warnings.add(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
      }

      // Parse books
      final bookParseParams = _BookParseParams(
        yamlData['books'],
        authorMap,
        tags,
      );
      final Either<Failure, _BookParseResult> bookResultEither =
          await _parseBooks(bookParseParams);
      final bookResult = bookResultEither.match(
        (failure) => throw ServiceFailure('Parse error'),
        (result) => result,
      );
      final parsedBooks = bookResult.books;
      logger?.info('Parsed ${parsedBooks.length} books');
      if (bookResult.errors.isNotEmpty) {
        logger?.warning('Parse errors encountered:');
        for (final error in bookResult.errors) {
          logger?.warning(error);
        }
      }
      // Since we created missing authors, bookResult.missingAuthors should be empty now
      assert(bookResult.missingAuthors.isEmpty);

      // Filter out duplicates within parsed books and against existing if not overwrite
      final List<Book> books = [];
      final List<String> duplicateWarnings = [];

      // First, filter duplicates within parsed books
      for (final book in parsedBooks) {
        final isDuplicateInParsed = books.any((existing) {
          final duplicateResult = isBookDuplicateUsecase(
            bookA: book,
            bookB: existing,
          );
          return duplicateResult.match((failure) {
            logger?.warning('Failed to check duplicate: ${failure.message}');
            return false;
          }, (isDup) => isDup);
        });
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
        final existingBooksEither = await dataAccess.bookRepository.getBooks();
        final existingBooks = existingBooksEither.match(
          (failure) => throw ServiceFailure('Parse error'),
          (books) => books,
        );
        final List<Book> finalBooks = [];
        for (final book in books) {
          final isDuplicateExisting = existingBooks.any((existing) {
            final duplicateResult = isBookDuplicateUsecase(
              bookA: book,
              bookB: existing,
            );
            return duplicateResult.match((failure) {
              logger?.warning('Failed to check duplicate: ${failure.message}');
              return false;
            }, (isDup) => isDup);
          });
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

      logger?.info('Starting database write operations...');

      // Use unit of work for batch operations
      final transactionResult = await dataAccess.unitOfWork.run((txn) async {
        // Save authors
        for (final author in authors) {
          final saveResult = await dataAccess.authorRepository.addAuthor(
            author: author,
            txn: txn,
          );
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save author failed'),
            );
          }
        }
        logger?.info('Saved ${authors.length} authors to database');

        // Save tags
        for (final tag in tags) {
          final saveResult = await dataAccess.tagRepository.addTag(
            tag: tag,
            txn: txn,
          );
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save tag failed'),
            );
          }
        }
        logger?.info('Saved ${tags.length} tags to database');

        // Save books
        for (final book in books) {
          final saveResult = await dataAccess.bookRepository.addBook(
            book: book,
            txn: txn,
          );
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save book failed'),
            );
          }
        }
        logger?.info('Saved ${books.length} books to database');
      });
      if (transactionResult.isLeft()) {
        return Left(
          transactionResult.getLeft().getOrElse(
            () => ServiceFailure('Transaction failed'),
          ),
        );
      }
      logger?.info('Committed all database operations in transaction');

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

      logger?.info('Successfully imported library');
      return Right(importResult);
    } catch (e) {
      logger?.error('Failed to import library: $e');
      return Left(ServiceFailure('Failed to import library: $e'));
    }
  }
}
