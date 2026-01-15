import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';
import 'package:sembast/sembast.dart';

/// Implementation of book repository using Sembast.
class BookRepositoryImpl implements BookRepository {
  final SembastDatabase _database;
  final BookIdRegistryService _idRegistryService;

  /// Creates a BookRepositoryImpl instance.
  BookRepositoryImpl({
    required DatabaseService database,
    required BookIdRegistryService idRegistryService,
  }) : _database = database as SembastDatabase,
       _idRegistryService = idRegistryService;

  final logger = Logger('BookRepositoryImpl');

  /// Retrieves books from the database with optional pagination.
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
          logger.severe(
            'BookRepositoryImpl: Failed to parse book record ${record.key}: $e',
          );
          return Either.left(DataParsingFailure(e.toString()));
        }
        authorIds.addAll(model.authorIds.cast<String>());
        tagIds.addAll(model.tagIds.cast<String>());
      }

      final authorRecords = <RecordSnapshot>[];
      if (authorIds.isNotEmpty) {
        for (final authorId in authorIds) {
          final records = await _database.authorsStore.find(
            db,
            finder: Finder(filter: Filter.equals('id', authorId)),
          );
          authorRecords.addAll(records);
        }
      }

      final tagRecords = <RecordSnapshot>[];
      if (tagIds.isNotEmpty) {
        for (final tagId in tagIds) {
          final records = await _database.tagsStore.find(
            db,
            finder: Finder(filter: Filter.equals('id', tagId)),
          );
          tagRecords.addAll(records);
        }
      }

      final authorMap = <String, AuthorModel>{};
      for (final record in authorRecords) {
        try {
          authorMap[record.key.toString()] = AuthorModel.fromMap(
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
          logger.info('model.authorIds: ${model.authorIds}');
          logger.info('authors length: ${authors.length}');
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

  /// Retrieves a book by its handle.
  @override
  Future<Either<Failure, Book?>> getBookByHandle({
    required BookHandle handle,
  }) async {
    logger.info('Entering getBookByHandle with handle: $handle');
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      final record = await _database.booksStore.findFirst(
        db,
        finder: Finder(filter: Filter.equals('id', handle.toString())),
      );
      if (record == null) {
        return Either.right(null);
      }
      final model = BookModel.fromMap(map: record.value);
      // Need to load authors and tags
      final authorIds = model.authorIds;
      final tagIds = model.tagIds;
      final authors = <Author>[];
      final tags = <Tag>[];
      for (final authorId in authorIds) {
        final authorRecord = await _database.authorsStore.findFirst(
          db,
          finder: Finder(filter: Filter.equals('id', authorId)),
        );
        if (authorRecord != null) {
          final authorModel = AuthorModel.fromMap(map: authorRecord.value);
          authors.add(authorModel.toEntity());
        }
      }
      for (final tagId in tagIds) {
        final tagRecord = await _database.tagsStore.findFirst(
          db,
          finder: Finder(filter: Filter.equals('id', tagId)),
        );
        if (tagRecord != null) {
          final tagModel = TagModel.fromMap(map: tagRecord.value);
          tags.add(tagModel.toEntity());
        }
      }
      final book = model.toEntity(authors: authors, tags: tags);
      logger.fine('Output: ${book.title}');
      logger.fine('Exiting getBookByHandle');
      return Either.right(book);
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Retrieves a book by its ID pair.
  @override
  Future<Either<Failure, Book?>> getBookByIdPair({
    required BookIdPair bookIdPair,
  }) async {
    logger.info('Entering getBookByIdPair with bookIdPair: $bookIdPair');
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
          .where((b) => b.businessIds.any((p) => p == bookIdPair))
          .firstOrNull;
      logger.fine('Output: ${book?.title ?? 'null'}');
      logger.fine('Exiting getBookByIdPair');
      return Either.right(book);
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Adds a new book to the database.
  @override
  Future<Either<Failure, BookHandle>> addBook({required Book book}) async {
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

      final handle = BookHandle.generate();
      final key = handle.toString();
      final model = BookModel.fromEntity(book, key);
      await db.transaction((txn) async {
        await _database.booksStore.record(key).put(txn, model.toMap());
        logger.info('Registering book ID pairs');
        final registerResult = _idRegistryService.registerBookIdPairs(
          BookIdPairs(pairs: book.businessIds),
        );
        if (registerResult.isLeft()) {
          throw registerResult.getLeft().getOrElse(
            () => RegistryFailure('Register ID pairs failed'),
          );
        }
        final result = await _updateRelationshipsForBook(
          key: key,
          book: book,
          isAdd: true,
          db: txn,
        );
        if (result.isLeft()) {
          throw result.getLeft().getOrElse(
            () => DatabaseFailure('Transaction failed'),
          );
        }
        return unit;
      });
      logger.info('BookRepositoryImpl: Success added book ${book.title}');
      logger.info('BookRepositoryImpl: Exiting addBook');
      return Either.right(handle);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Updates an existing book in the database.
  @override
  Future<Either<Failure, Unit>> updateBook({required Book book}) async {
    logger.info(
      'BookRepositoryImpl: Entering updateBook with book: ${book.title}',
    );
    try {
      Database db;
      try {
        db = await _database.database;
      } catch (e) {
        return Either.left(DatabaseConnectionFailure(e.toString()));
      }
      // Find the record key by matching businessIds
      final records = await _database.booksStore.find(db);
      String? foundKey;
      for (final record in records) {
        final model = BookModel.fromMap(map: record.value);
        if (BookIdPairs(pairs: model.businessIds) ==
            BookIdPairs(pairs: book.businessIds)) {
          foundKey = record.key;
          break;
        }
      }
      if (foundKey == null) {
        return Either.left(DatabaseReadFailure('Book not found'));
      }
      final key = foundKey;
      // Get existing book
      final eitherExisting = await getBookByHandle(handle: BookHandle(key));
      final existing = eitherExisting.getOrElse((failure) => null);
      await db.transaction((txn) async {
        if (existing != null) {
          logger.info('Unregistering old book ID pairs');
          final unregisterResult = _idRegistryService.unregisterBookIdPairs(
            BookIdPairs(pairs: existing.businessIds),
          );
          if (unregisterResult.isLeft()) {
            throw unregisterResult.getLeft().getOrElse(
              () => RegistryFailure('Unregister ID pairs failed'),
            );
          }
          final result = await _updateRelationshipsForBook(
            key: key,
            book: existing,
            isAdd: false,
            db: txn,
          );
          if (result.isLeft()) {
            throw result.getLeft().getOrElse(
              () => DatabaseFailure('Transaction failed'),
            );
          }
        }
        final model = BookModel.fromEntity(book, key);
        await _database.booksStore.record(key).put(txn, model.toMap());
        logger.info('Registering new book ID pairs');
        final registerResult = _idRegistryService.registerBookIdPairs(
          BookIdPairs(pairs: book.businessIds),
        );
        if (registerResult.isLeft()) {
          throw registerResult.getLeft().getOrElse(
            () => RegistryFailure('Register ID pairs failed'),
          );
        }
        final result = await _updateRelationshipsForBook(
          key: key,
          book: book,
          isAdd: true,
          db: txn,
        );
        if (result.isLeft()) {
          throw result.getLeft().getOrElse(
            () => DatabaseFailure('Transaction failed'),
          );
        }
        return unit;
      });
      logger.info('BookRepositoryImpl: Success updated book ${book.title}');
      logger.info('BookRepositoryImpl: Exiting updateBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Deletes a book from the database.
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
      // Find the record key by matching businessIds
      final records = await _database.booksStore.find(db);
      String? foundKey;
      for (final record in records) {
        final model = BookModel.fromMap(map: record.value);
        if (BookIdPairs(pairs: model.businessIds) ==
            BookIdPairs(pairs: book.businessIds)) {
          foundKey = record.key;
          break;
        }
      }
      if (foundKey == null) {
        return Either.left(DatabaseReadFailure('Book not found'));
      }
      final key = foundKey;
      await db.transaction((txn) async {
        logger.info('Unregistering book ID pairs');
        final unregisterResult = _idRegistryService.unregisterBookIdPairs(
          BookIdPairs(pairs: book.businessIds),
        );
        if (unregisterResult.isLeft()) {
          throw unregisterResult.getLeft().getOrElse(
            () => RegistryFailure('Unregister ID pairs failed'),
          );
        }
        await _database.booksStore.record(key).delete(txn);
        final result = await _updateRelationshipsForBook(
          key: key,
          book: book,
          isAdd: false,
          db: txn,
        );
        if (result.isLeft()) {
          throw result.getLeft().getOrElse(
            () => DatabaseFailure('Transaction failed'),
          );
        }
        return unit;
      });
      logger.info('BookRepositoryImpl: Success deleted book ${book.title}');
      logger.info('BookRepositoryImpl: Exiting deleteBook');
      return Either.right(unit);
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _updateRelationshipsForBook({
    required String key,
    required Book book,
    required bool isAdd,
    required Transaction db,
  }) async {
    logger.info(
      'BookRepositoryImpl: Entering _updateRelationshipsForBook with book: ${book.title}, isAdd: $isAdd',
    );
    try {
      for (final tag in book.tags) {
        final tagRecord = await _database.tagsStore.findFirst(
          db,
          finder: Finder(filter: Filter.equals('id', tag.id.toString())),
        );
        if (tagRecord != null) {
          final tagKey = tagRecord.key;
          TagModel tagModel;
          try {
            tagModel = TagModel.fromMap(map: tagRecord.value);
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
          final updatedBookIds = List<String>.from(tagModel.bookIdPairs);
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
            color: tagModel.color,
            slug: tagModel.slug,
            bookIdPairs: updatedBookIds,
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

  /// Retrieves books by a specific author.
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

  /// Retrieves books by a specific tag.
  @override
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag}) async {
    logger.info(
      'BookRepositoryImpl: Entering getBooksByTag with tag: ${tag.name}',
    );
    try {
      final booksEither = await getBooks(); // Get all books
      return booksEither.map((allBooks) {
        final booksByTag = allBooks
            .where((book) => book.tags.any((t) => t.id == tag.id))
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

  /// Retrieves a book by its ID pairs.
  @override
  Future<Either<Failure, Book?>> getBookById({
    required BookIdPairs bookId,
  }) async {
    logger.info('Entering getBookById with bookId: $bookId');
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
          .where((b) => BookIdPairs(pairs: b.businessIds) == bookId)
          .firstOrNull;
      logger.info('Output: ${book?.title ?? 'null'}');
      logger.info('Exiting getBookById');
      return Either.right(book);
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }
}
