import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:sembast/sembast.dart';

class BookRepositoryImpl implements IBookRepository {
  final SembastDatabase _database;
  final IsBookDuplicateUsecase _isBookDuplicateUsecase;

  BookRepositoryImpl({
    required SembastDatabase database,
    required IsBookDuplicateUsecase isBookDuplicateUsecase,
  }) : _database = database,
       _isBookDuplicateUsecase = isBookDuplicateUsecase;

  final logger = DevLogger('BookRepositoryImpl');

  @override
  Future<Either<Failure, List<Book>>> getBooks({
    int? limit,
    int? offset,
  }) async {
    logger.info('BookRepositoryImpl: Entering getBooks');
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      final finder = Finder(limit: limit, offset: offset);
      final records = await _database.booksStore.find(db, finder: finder);

      final authorIds = <String>{};
      final tagIds = <String>{};
      for (final record in records) {
        logger.info(
          'BookRepositoryImpl: Processing book record key: ${record.key}',
        );
        logger.info('BookRepositoryImpl: Record value: ${record.value}');
        BookModel model;
        try {
          model = BookModel.fromMap(map: record.value);
        } catch (e) {
          logger.error(
            'BookRepositoryImpl: Failed to parse book record ${record.key}: $e',
          );
          return Either.left(DataParsingFailure(e.toString()));
        }
        authorIds.addAll(model.authorIds.cast<String>());
        tagIds.addAll(model.tagIds.cast<String>());
      }

      final authorRecords = authorIds.isNotEmpty
          ? (await _database.authorsStore
                    .records(authorIds.cast<String>())
                    .get(db))
                .whereType<RecordSnapshot>()
                .toList()
          : [];

      final tagRecords = tagIds.isNotEmpty
          ? (await _database.tagsStore.records(tagIds.cast<String>()).get(db))
                .whereType<RecordSnapshot>()
                .toList()
          : [];

      final authorMap = <String, AuthorModel>{};
      for (final record in authorRecords) {
        try {
          authorMap[record.key as String] = AuthorModel.fromMap(
            map: record.value as Map<String, dynamic>,
          );
        } catch (e) {
          continue;
        }
      }

      final tagMap = <String, TagModel>{};
      for (final record in tagRecords) {
        try {
          tagMap[record.key.toString()] = TagModel.fromMap(
            map: record.value as Map<String, dynamic>,
          );
        } catch (e) {
          continue;
        }
      }

      final books = <Book>[];
      for (final record in records) {
        try {
          final model = BookModel.fromMap(map: record.value);
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
      logger.info(
        'BookRepositoryImpl: Success in getBooks, fetched ${books.length} books',
      );
      logger.info(
        'BookRepositoryImpl: Output: ${books.map((b) => b.title).toList()}',
      );
      logger.info('BookRepositoryImpl: Exiting getBooks');
      return Either.right(books);
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book?>> getBookByIdPairPair({
    required BookIdPair bookIdPair,
  }) async {
    logger.info(
      'BookRepositoryImpl: Entering getBookByIdPairPair with bookIdPair: $bookIdPair',
    );
    try {
      final booksEither = await getBooks();
      if (booksEither.isLeft()) {
        return Either.left(
          booksEither.getLeft().getOrElse(
            () => DatabaseFailure('Failed to get books'),
          ),
        );
      }
      final books = booksEither.getRight().getOrElse(() => []);
      final book = books
          .where((b) => b.idPairs.idPairs.any((p) => p == bookIdPair))
          .firstOrNull;
      logger.info('BookRepositoryImpl: Output: ${book?.title ?? 'null'}');
      logger.info('BookRepositoryImpl: Exiting getBookByIdPairPair');
      return Either.right(book);
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addBook({required Book book}) async {
    logger.info(
      'BookRepositoryImpl: Entering addBook with book: ${book.title}',
    );
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }

      // Check for duplicates
      final existingBooksEither = await getBooks();
      if (existingBooksEither.isLeft()) {
        return Either.left(
          existingBooksEither.getLeft().getOrElse(
            () => DatabaseFailure('Failed to check existing books'),
          ),
        );
      }
      final existingBooks = existingBooksEither.getRight().getOrElse(() => []);
      final isDuplicate = existingBooks.any(
        (existing) => _isBookDuplicateUsecase
            .call(bookA: book, bookB: existing)
            .getRight()
            .getOrElse(() => false),
      );
      if (isDuplicate) {
        logger.warning(
          'BookRepositoryImpl: Duplicate book detected: ${book.title}',
        );
        return Either.left(
          ValidationFailure(
            'A book with the same title, authors, and ID pairs already exists',
          ),
        );
      }

      final key = book.key;
      final model = BookModel.fromEntity(book: book);
      await _database.booksStore.record(key).put(db, model.toMap());
      final result = await _updateRelationshipsForBook(key, book, isAdd: true);
      if (result.isLeft()) return result;
      logger.info('BookRepositoryImpl: Success added book ${book.title}');
      logger.info('BookRepositoryImpl: Exiting addBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateBook({required Book book}) async {
    logger.info(
      'BookRepositoryImpl: Entering updateBook with book: ${book.title}',
    );
    final key = book.key;
    final eitherExisting = await getBookByIdPairPair(
      bookIdPair: book.idPairs.idPairs.first,
    );
    final existing = eitherExisting.getOrElse((failure) => null);
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      if (existing != null) {
        final result = await _updateRelationshipsForBook(
          existing.key,
          existing,
          isAdd: false,
        );
        if (result.isLeft()) return result;
      }
      final model = BookModel.fromEntity(book: book);
      await _database.booksStore.record(key).put(db, model.toMap());
      final result = await _updateRelationshipsForBook(key, book, isAdd: true);
      if (result.isLeft()) return result;
      logger.info('BookRepositoryImpl: Success updated book ${book.title}');
      logger.info('TagRepositoryImpl: Exiting updateBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBook({required Book book}) async {
    logger.info(
      'BookRepositoryImpl: Entering deleteBook with book: ${book.title}',
    );
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      final key = book.key;
      await _database.booksStore.record(key).delete(db);
      final result = await _updateRelationshipsForBook(key, book, isAdd: false);
      if (result.isLeft()) return result;
      logger.info('BookRepositoryImpl: Success deleted book ${book.title}');
      logger.info('BookRepositoryImpl: Exiting deleteBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _updateRelationshipsForBook(
    String key,
    Book book, {
    required bool isAdd,
  }) async {
    logger.info(
      'BookRepositoryImpl: Entering _updateRelationshipsForBook with book: ${book.title}, isAdd: $isAdd',
    );
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      for (final authorName in book.authors.map((a) => a.name)) {
        final authorRecord = await _database.authorsStore.findFirst(
          db,
          finder: Finder(filter: Filter.equals('name', authorName)),
        );
        if (authorRecord != null) {
          final authorKey = authorRecord.key;
          AuthorModel authorModel;
          try {
            authorModel = AuthorModel.fromMap(map: authorRecord.value);
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
          final updatedBookIds = List<String>.from(authorModel.bookIds);
          if (isAdd) {
            if (!updatedBookIds.contains(key)) {
              updatedBookIds.add(key);
            }
          } else {
            updatedBookIds.remove(key);
          }
          final updatedAuthorModel = AuthorModel(
            id: authorModel.id,
            idPairs: authorModel.idPairs,
            name: authorModel.name,
            biography: authorModel.biography,
            bookIds: updatedBookIds,
          );
          await _database.authorsStore
              .record(authorKey)
              .put(db, updatedAuthorModel.toMap());
        }
      }
      for (final tagName in book.tags.map((t) => t.name)) {
        final tagRecord = await _database.tagsStore.findFirst(
          db,
          finder: Finder(filter: Filter.equals('name', tagName)),
        );
        if (tagRecord != null) {
          final tagKey = tagRecord.key;
          TagModel tagModel;
          try {
            tagModel = TagModel.fromMap(map: tagRecord.value);
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
          final updatedBookIds = List<String>.from(tagModel.bookIds);
          if (isAdd) {
            if (!updatedBookIds.contains(key)) {
              updatedBookIds.add(key);
            }
          } else {
            updatedBookIds.remove(key);
          }
          final updatedTagModel = TagModel(
            id: tagModel.id,
            name: tagModel.name,
            description: tagModel.description,
            bookIds: updatedBookIds,
          );
          await _database.tagsStore
              .record(tagKey)
              .put(db, updatedTagModel.toMap());
        }
      }
      logger.info('BookRepositoryImpl: Success in _updateRelationshipsForBook');
      logger.info('BookRepositoryImpl: Exiting _updateRelationshipsForBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseConstraintFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getBooksByAuthor({
    required Author author,
  }) async {
    logger.info(
      'BookRepositoryImpl: Entering getBooksByAuthor with author: ${author.name}',
    );
    try {
      final booksEither = await getBooks(); // Get all books
      return booksEither.map((allBooks) {
        final booksByAuthor = allBooks
            .where((book) => book.authors.any((a) => a.name == author.name))
            .toList();
        logger.info(
          'BookRepositoryImpl: Found ${booksByAuthor.length} books for author ${author.name}',
        );
        return booksByAuthor;
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag}) async {
    logger.info(
      'BookRepositoryImpl: Entering getBooksByTag with tag: ${tag.name}',
    );
    try {
      final booksEither = await getBooks(); // Get all books
      return booksEither.map((allBooks) {
        final booksByTag = allBooks
            .where((book) => book.tags.any((t) => t.name == tag.name))
            .toList();
        logger.info(
          'BookRepositoryImpl: Found ${booksByTag.length} books for tag ${tag.name}',
        );
        return booksByTag;
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }
}
