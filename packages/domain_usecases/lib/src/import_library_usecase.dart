import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'is_book_duplicate_usecase.dart';
import 'package:slugify_string/slugify_string.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

/// Use case for importing a library from a file.
class ImportLibraryUsecase with Loggable {
  final LibraryDataAccess dataAccess;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;
  final LibraryFileLoader fileLoader;

  ImportLibraryUsecase({
    required this.dataAccess,
    required this.isBookDuplicateUsecase,
    required this.fileLoader,
  });

  /// Parses authors from YAML data.
  TaskEither<Failure, Map<String, Author>> _parseAuthors(dynamic yamlAuthors) {
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
    );
  }

  /// Parses tags from YAML data.
  TaskEither<Failure, List<Tag>> _parseTags(dynamic yamlTags) {
    return TaskEither.tryCatch(() async {
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
    }, (error, stackTrace) => ParsingFailure('Failed to parse tags: $error'));
  }

  /// Parses books from YAML data with parameters.
  TaskEither<Failure, BookParseResult> _parseBooks(BookParseParams params) {
    return TaskEither.tryCatch(() async {
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
            title: originalTitle,
            originalTitle: originalTitle,
            authors: bookAuthors,
            tags: bookTags,
            publishedDate: publishedDate,
          ),
        );
      }
      return BookParseResult(books, errors, missingAuthors.toList());
    }, (error, stackTrace) => ParsingFailure('Failed to parse books: $error'));
  }

  /// Imports a library from the specified file path.
  TaskEither<Failure, ImportResult> call({
    required String filePath,
    bool overwrite = false,
  }) {
    logger?.info(
      'ImportLibraryUsecase: Importing library from $filePath, overwrite: $overwrite',
    );

    // Read and parse YAML file via injected loader
    return fileLoader.loadYaml(filePath).flatMap((yamlData) {
      logger?.info('Parsed YAML data, keys: ${yamlData.keys}');

      // Validate required sections
      if (yamlData['books'] == null) {
        return TaskEither<Failure, ImportResult>.left(
          ServiceFailure('Invalid YAML format: books section is required'),
        );
      }

      // Handle overwrite: clear all existing data atomically if requested.
      final clearTask = overwrite
          ? dataAccess.unitOfWork.run(
              (txn) => dataAccess.bookRepository
                  .deleteAll(txn: txn)
                  .flatMap((_) => dataAccess.tagRepository.deleteAll(txn: txn))
                  .flatMap((_) => dataAccess.authorRepository.deleteAll(txn: txn))
                  .map((_) {
                    logger?.info('Existing data cleared');
                    return unit;
                  }),
            )
          : TaskEither<Failure, Unit>.right(unit);

      return clearTask.flatMap((_) {
        // Parse authors (optional)
        final parseAuthorsTask = yamlData['authors'] != null
            ? _parseAuthors(yamlData['authors'])
            : TaskEither<Failure, Map<String, Author>>.right(
                <String, Author>{},
              );

        return parseAuthorsTask.flatMap((authorMap) {
          logger?.info('Parsed ${authorMap.length} authors');

          // Parse tags (optional)
          final parseTagsTask = yamlData['tags'] != null
              ? _parseTags(yamlData['tags'])
              : TaskEither<Failure, List<Tag>>.right(<Tag>[]);

          return parseTagsTask.flatMap((tags) {
            logger?.info('Parsed ${tags.length} tags');

            // Process books with author/tag resolution
            return _processBooks(yamlData['books'], authorMap, tags).flatMap((
              bookProcessingResult,
            ) {
              final processedBooks = bookProcessingResult.books;
              final warnings = bookProcessingResult.warnings;
              final parseErrors = bookProcessingResult.parseErrors;

              // Filter duplicates
              return _filterDuplicates(processedBooks, overwrite).flatMap((
                filteredResult,
              ) {
                final finalBooks = filteredResult.books;
                final duplicateWarnings = filteredResult.warnings;
                warnings.addAll(duplicateWarnings);

                // Recompute authors list (include any authors created while
                // processing books) and save to database
                final finalAuthors = authorMap.values.toList();
                return _saveToDatabase(finalAuthors, tags, finalBooks).map((_) {
                  final library = Library(
                    name: yamlData['name'] as String? ?? 'Imported Library',
                    description:
                        yamlData['description'] as String? ??
                        'Imported from $filePath',
                    books: finalBooks,
                    authors: finalAuthors,
                    tags: tags,
                  );

                  logger?.info('Successfully imported library');
                  return ImportResult(
                    library: library,
                    parseErrors: parseErrors,
                    warnings: warnings,
                  );
                });
              });
            });
          });
        });
      });
    });
  }

  TaskEither<Failure, BookProcessingResult> _processBooks(
    dynamic yamlBooks,
    Map<String, Author> authorMap,
    List<Tag> tags,
  ) {
    return TaskEither.tryCatch(() async {
      final yamlBooksList = yamlBooks as YamlList;
      final allBookTagNames = <String>{};
      final allBookAuthorNames = <String>{};

      // Collect all tag and author names from books
      for (final yamlBook in yamlBooksList) {
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

      // Find missing tags
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
      final warnings = <String>[];
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
        authorMap[authorName] = author;
      }

      if (missingAuthorNames.isNotEmpty) {
        logger?.info(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
        warnings.add(
          'Created ${missingAuthorNames.length} missing authors: ${missingAuthorNames.join(', ')}',
        );
      }

      // Parse books
      final bookParseParams = BookParseParams(yamlBooks, authorMap, tags);
      final bookResultEither = await _parseBooks(bookParseParams).run();
      return bookResultEither.match((failure) => throw failure, (bookResult) {
        logger?.info('Parsed ${bookResult.books.length} books');
        if (bookResult.errors.isNotEmpty) {
          logger?.warning('Parse errors encountered:');
          for (final error in bookResult.errors) {
            logger?.warning(error);
          }
        }

        return BookProcessingResult(
          bookResult.books,
          warnings,
          bookResult.errors,
        );
      });
    }, (error, stackTrace) => ParsingFailure('Failed to process books: $error'));
  }

  TaskEither<Failure, DuplicateFilterResult> _filterDuplicates(
    List<Book> books,
    bool overwrite,
  ) {
    // Filter duplicates within parsed books
    final filteredBooks = <Book>[];
    final warnings = <String>[];

    for (final book in books) {
      bool isDuplicate = false;
      for (final existing in filteredBooks) {
        final duplicateResult = isBookDuplicateUsecase(
          bookA: book,
          bookB: existing,
        );
        isDuplicate = duplicateResult.fold((failure) {
          logger?.warning('Failed to check duplicate: ${failure.message}');
          return false;
        }, (isDup) => isDup);
        if (isDuplicate) break;
      }
      if (!isDuplicate) {
        filteredBooks.add(book);
      } else {
        warnings.add('Skipped duplicate book in import: ${book.title}');
      }
    }

    // If not overwrite, check against existing books
    if (!overwrite) {
      return dataAccess.bookRepository.getBooks().map((
        List<Book> existingBooks,
      ) {
        final finalBooks = <Book>[];
        for (final book in filteredBooks) {
          bool isDuplicate = false;
          for (final existing in existingBooks) {
            final duplicateResult = isBookDuplicateUsecase(
              bookA: book,
              bookB: existing,
            );
            isDuplicate = duplicateResult.fold((failure) {
              logger?.warning('Failed to check duplicate: ${failure.message}');
              return false;
            }, (isDup) => isDup);
            if (isDuplicate) break;
          }
          if (!isDuplicate) {
            finalBooks.add(book);
          } else {
            warnings.add(
              'Skipped existing duplicate book in import: ${book.title}',
            );
          }
        }
        return DuplicateFilterResult(finalBooks, warnings);
      });
    } else {
      return TaskEither.right(DuplicateFilterResult(filteredBooks, warnings));
    }
  }

  /// Saves [authors], [tags] and [books] to the database inside a single
  /// atomic transaction.
  ///
  /// All three entity types are enlisted in the same [UnitOfWork.run] callback
  /// so that a failure in any step rolls back all previous writes atomically.
  TaskEither<Failure, Unit> _saveToDatabase(
    List<Author> authors,
    List<Tag> tags,
    List<Book> books,
  ) {
    logger?.info('Starting database write operations…');

    return dataAccess.unitOfWork.run((txn) {
      // Chain all saves sequentially inside the open transaction.
      // Each repo call receives `txn` so it joins the same Sembast transaction.
      TaskEither<Failure, Unit> chain = TaskEither.right(unit);

      for (final author in authors) {
        chain = chain.flatMap(
          (_) => dataAccess.authorRepository.create(item: author, txn: txn).map((_) {
            logger?.info('Saved author: ${author.name}');
            return unit;
          }),
        );
      }

      for (final tag in tags) {
        chain = chain.flatMap(
          (_) => dataAccess.tagRepository.create(item: tag, txn: txn).map((_) {
            logger?.info('Saved tag: ${tag.name}');
            return unit;
          }),
        );
      }

      for (final book in books) {
        chain = chain.flatMap(
          (_) => dataAccess.bookRepository.create(item: book, txn: txn).map((_) {
            logger?.info('Saved book: ${book.title}');
            return unit;
          }),
        );
      }

      return chain.map((_) {
        logger?.info(
          'Saved ${authors.length} authors, ${tags.length} tags, '
          '${books.length} books',
        );
        return unit;
      });
    });
  }
}
