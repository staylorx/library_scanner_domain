import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:yaml/yaml.dart';

/// Use case for importing a library from a file.
class ImportLibraryUsecase with Loggable {
  final UnitOfWork unitOfWork;
  final DatabaseService databaseService;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;
  final AuthorDatasource authorDatasource;
  final BookDatasource bookDatasource;
  final TagDatasource tagDatasource;

  ImportLibraryUsecase({
    Logger? logger,
    required this.unitOfWork,
    required this.databaseService,
    required this.isBookDuplicateUsecase,
    required this.authorDatasource,
    required this.bookDatasource,
    required this.tagDatasource,
  });

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
        final clearResult = await databaseService.clearAll();
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
        (failure) => throw ServiceFailure(
          'Parse error',
        ), // Let the outer try-catch handle it
        (map) => map,
      );
      final authors = authorMap.values.toList();
      logger?.info('Parsed ${authors.length} authors');

      // Parse tags (optional, default empty)
      final Either<Failure, List<Tag>> tagsEither = yamlData['tags'] != null
          ? await parseTags(yamlData['tags'])
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
          final duplicateResult = isBookDuplicateUsecase.call(
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
        final existingBooksEither = await bookDatasource.getAllBooks();
        final authorsEither = await authorDatasource.getAllAuthors();
        final tagsEither = await tagDatasource.getAllTags();
        final authors = authorsEither.match(
          (failure) => throw ServiceFailure('Parse error'),
          (models) => models.map((m) => m.toEntity()).toList(),
        );
        final tags = tagsEither.match(
          (failure) => throw ServiceFailure('Parse error'),
          (models) => models.map((m) => m.toEntity()).toList(),
        );
        final existingBooks = existingBooksEither.match(
          (failure) => throw ServiceFailure('Parse error'),
          (models) => models
              .map((m) => m.toEntity(authors: authors, tags: tags))
              .toList(),
        );
        final List<Book> finalBooks = [];
        for (final book in books) {
          final isDuplicateExisting = existingBooks.any((existing) {
            final duplicateResult = isBookDuplicateUsecase.call(
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
      final transactionResult = await unitOfWork.run((txn) async {
        final db = (txn as SembastTransaction).db;
        // Save authors
        for (final author in authors) {
          final authorModel = AuthorModel.fromEntity(author, author.name);
          final saveResult = await authorDatasource.saveAuthor(
            authorModel,
            db: db,
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
          final saveResult = await tagDatasource.saveTag(tagModel, db: db);
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
          final saveResult = await bookDatasource.saveBook(bookModel, db: db);
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
