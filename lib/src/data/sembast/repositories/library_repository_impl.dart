import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/src/data/storage/library_datasource.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Implementation of library repository.
class LibraryRepositoryImpl with Loggable implements LibraryRepository {
  final IsBookDuplicateUsecase _isBookDuplicateUsecase;
  final AuthorDatasource _authorDatasource;
  final BookDatasource _bookDatasource;
  final TagDatasource _tagDatasource;
  final LibraryDatasource _libraryDatasource;

  LibraryRepositoryImpl({
    Logger? logger,
    required IsBookDuplicateUsecase isBookDuplicateUsecase,
    required AuthorDatasource authorDatasource,
    required BookDatasource bookDatasource,
    required TagDatasource tagDatasource,
    required LibraryDatasource libraryDatasource,
  }) : _isBookDuplicateUsecase = isBookDuplicateUsecase,
       _authorDatasource = authorDatasource,
       _bookDatasource = bookDatasource,
       _tagDatasource = tagDatasource,
       _libraryDatasource = libraryDatasource {
    this.logger = logger;
  }

  /// Imports a library from a YAML file.
  @override
  Future<Either<Failure, ImportResult>> importLibrary(
    String filePath, {
    bool overwrite = false,
  }) async {
    logger?.info(
      'Entering importLibrary with filePath: $filePath, overwrite: $overwrite',
    );
    try {
      final file = File(filePath);
      final yamlString = await file.readAsString();
      final yamlData = await parseYamlData(yamlString);
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
        final clearResult = await _libraryDatasource.clearAll();
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
          ? await parseAuthors(yamlData['authors'])
          : Right(<String, Author>{});
      final authorMap = authorMapEither.match(
        (failure) => throw failure, // Let the outer try-catch handle it
        (map) => map,
      );
      final authors = authorMap.values.toList();
      logger?.info('Parsed ${authors.length} authors');

      // Parse tags (optional, default empty)
      final Either<Failure, List<Tag>> tagsEither = yamlData['tags'] != null
          ? await parseTags(yamlData['tags'])
          : Right(<Tag>[]);
      final tags = tagsEither.match((failure) => throw failure, (list) => list);
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
          .where((name) => !existingTagSlugs.contains(computeSlug(name)))
          .toSet();

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
        logger?.info(
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
      final Either<Failure, BookParseResult> bookResultEither =
          await parseBooks(bookParseParams);
      final bookResult = bookResultEither.match(
        (failure) => throw failure,
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
          final duplicateResult = _isBookDuplicateUsecase.call(
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
        final existingBooksEither = await _bookDatasource.getAllBooks();
        final authorsEither = await _authorDatasource.getAllAuthors();
        final tagsEither = await _tagDatasource.getAllTags();
        final authors = authorsEither.match(
          (failure) => throw failure,
          (models) => models.map((m) => m.toEntity()).toList(),
        );
        final tags = tagsEither.match(
          (failure) => throw failure,
          (models) => models.map((m) => m.toEntity()).toList(),
        );
        final existingBooks = existingBooksEither.match(
          (failure) => throw failure,
          (models) => models
              .map((m) => m.toEntity(authors: authors, tags: tags))
              .toList(),
        );
        final List<Book> finalBooks = [];
        for (final book in books) {
          final isDuplicateExisting = existingBooks.any((existing) {
            final duplicateResult = _isBookDuplicateUsecase.call(
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

      // Use transaction for batch operations
      final transactionResult = await _bookDatasource.transaction((txn) async {
        // Save authors
        for (final author in authors) {
          final authorModel = AuthorModel.fromEntity(author, author.name);
          final saveResult = await _authorDatasource.saveAuthor(
            authorModel,
            db: txn,
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
          final tagModel = TagModel.fromEntity(tag);
          final saveResult = await _tagDatasource.saveTag(tagModel, db: txn);
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save tag failed'),
            );
          }
        }
        logger?.info('Saved ${tags.length} tags to database');

        // Save books
        for (final book in books) {
          final bookKey = BookHandle.generate();
          final bookModel = BookModel.fromEntity(book, bookKey.toString());
          final saveResult = await _bookDatasource.saveBook(bookModel, db: txn);
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

  /// Exports a library to a YAML file.
  @override
  Future<Either<Failure, Unit>> exportLibrary({
    required String filePath,
    required Library library,
  }) async {
    logger?.info('Entering exportLibrary with filePath: $filePath');
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
      logger?.info('Successfully exported library to $filePath');
      return Right(unit);
    } catch (e) {
      logger?.error('Failed to export library: $e');
      return Left(ServiceFailure('Failed to export library: $e'));
    }
  }

  /// Clears all data from the library.
  @override
  Future<Either<Failure, Unit>> clearLibrary() async {
    logger?.info('Entering clearLibrary');
    final clearResult = await _libraryDatasource.clearAll();
    return clearResult.match(
      (failure) {
        logger?.error('Failed to clear library: ${failure.message}');
        return Left(failure);
      },
      (_) {
        logger?.info('Successfully cleared library');
        return Right(unit);
      },
    );
  }
}
