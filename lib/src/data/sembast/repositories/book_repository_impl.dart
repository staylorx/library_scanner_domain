import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_transaction.dart';
import 'package:library_scanner_domain/src/domain/repositories/unit_of_work.dart';

/// Implementation of book repository using Sembast.
class BookRepositoryImpl with Loggable implements BookRepository {
  final BookDatasource _bookDatasource;
  final AuthorDatasource _authorDatasource;
  final TagDatasource _tagDatasource;
  final BookIdRegistryService _idRegistryService;
  final UnitOfWork _unitOfWork;

  /// Creates a BookRepositoryImpl instance.
  BookRepositoryImpl({
    required BookDatasource bookDatasource,
    required AuthorDatasource authorDatasource,
    required TagDatasource tagDatasource,
    required BookIdRegistryService idRegistryService,
    required UnitOfWork unitOfWork,
    Logger? logger,
  }) : _bookDatasource = bookDatasource,
       _authorDatasource = authorDatasource,
       _tagDatasource = tagDatasource,
       _idRegistryService = idRegistryService,
       _unitOfWork = unitOfWork;

  /// Retrieves books from the database.
  @override
  Future<Either<Failure, List<BookProjection>>> getBooks({
    int? limit,
    int? offset,
  }) async {
    logger?.info('Entering getBooks');
    final result = await _bookDatasource.getAllBooks();
    if (result.isLeft()) {
      final failure = result.getLeft().getOrElse(
        () => DatabaseFailure('Failed to get books'),
      );
      logger?.warning('Failed to get books: ${failure.message}');
      return Either.left(failure);
    }
    final models = result.getRight().getOrElse(() => []);
    final projections = <BookProjection>[];
    for (final model in models) {
      final book = await _loadBookWithRelations(model);
      final handle = BookHandle(model.id);
      projections.add(BookProjection(handle: handle, book: book));
    }
    logger?.info('Successfully retrieved ${projections.length} books');
    return Either.right(projections);
  }

  Future<Book> _loadBookWithRelations(BookModel model) async {
    // Load authors
    final authors = <Author>[];
    for (final authorId in model.authorIds) {
      final authorResult = await _authorDatasource.getAuthorById(authorId);
      authorResult.fold(
        (f) => null, // ignore failure
        (authorModel) {
          if (authorModel != null) {
            authors.add(authorModel.toEntity());
          }
        },
      );
    }
    // Load tags
    final tags = <Tag>[];
    for (final tagId in model.tagIds) {
      final tagResult = await _tagDatasource.getTagById(tagId);
      tagResult.fold(
        (f) => null, // ignore failure
        (tagModel) {
          if (tagModel != null) {
            tags.add(tagModel.toEntity());
          }
        },
      );
    }
    return model.toEntity(authors: authors, tags: tags);
  }

  /// Retrieves a book by its handle.
  @override
  Future<Either<Failure, Book>> getByHandle({
    required BookHandle handle,
  }) async {
    logger?.info('Entering getByHandle with handle: $handle');
    final result = await _bookDatasource.getBookById(handle.toString());
    if (result.isLeft()) {
      final failure = result.getLeft().getOrElse(
        () => DatabaseFailure('Failed to get book'),
      );
      logger?.warning(
        'Failed to get book by handle: $handle, Error: ${failure.message}',
      );
      return Either.left(failure);
    }
    final model = result.getRight().getOrElse(() => null);
    if (model == null) {
      logger?.info('Book with handle $handle not found');
      return Either.left(NotFoundFailure('Book not found'));
    }
    final book = await _loadBookWithRelations(model);
    logger?.info('Output: ${book.title}');
    return Either.right(book);
  }

  /// Retrieves a book by its ID pair.
  @override
  Future<Either<Failure, Book>> getByIdPair({
    required BookIdPair bookIdPair,
  }) async {
    logger?.info('Entering getByIdPair with bookIdPair: $bookIdPair');
    final result = await _bookDatasource.getBooksByBusinessIdPair(bookIdPair);
    return result.fold((failure) => Either.left(failure), (models) async {
      if (models.isEmpty) {
        logger?.debug('Book not found');
        return Either.left(NotFoundFailure('Book not found'));
      }
      final book = await _loadBookWithRelations(models.first);
      logger?.debug('Output: ${book.title}');
      return Either.right(book);
    });
  }

  // TODO: is there a way to do this without a transaction here, or perhaps create a custom
  // helper in the library_datasource. Maybe that's the library_datasource's job now

  /// Adds a new book to the database.
  @override
  Future<Either<Failure, BookProjection>> addBook({required Book book}) async {
    logger?.info('Entering addBook with book: ${book.title}');
    final handle = BookHandle.generate();
    final model = BookModel.fromEntity(book, handle.toString());
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for addBook');
      final db = (txn as SembastTransaction).db;
      final saveResult = await _bookDatasource.saveBook(model, db: db);
      if (saveResult.isLeft()) {
        throw saveResult.getLeft().getOrElse(
          () => DatabaseFailure('Save failed'),
        );
      }
      logger?.info('Book saved, registering ID pairs');
      final registerResult = _idRegistryService.registerBookIdPairs(
        BookIdPairs(pairs: book.businessIds),
      );
      if (registerResult.isLeft()) {
        throw registerResult.getLeft().getOrElse(
          () => RegistryFailure('Register ID pairs failed'),
        );
      }
      logger?.info('ID pairs registered, updating relationships');
      final tagNames = book.tags.map((t) => t.name).toList();
      final updateResult = await _tagDatasource.addBookToTags(
        handle.toString(),
        tagNames,
        db: db,
      );
      if (updateResult.isLeft()) {
        throw updateResult.getLeft().getOrElse(
          () => DatabaseFailure('Update relationships failed'),
        );
      }
      logger?.info('Transaction operation completed for addBook');
      return BookProjection(handle: handle, book: book);
    });
  }

  // TODO: similar comment as addBook(); must sort out the transaction way of doing all this.
  // This begs the question how much of changing can one do: update the book,
  // but tags too? What if I change the author's name, maybe add their middle initial?
  /// Updates an existing book in the database.
  @override
  Future<Either<Failure, Unit>> updateBook({required Book book}) async {
    logger?.info('Entering updateBook with book: ${book.title}');
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for updateBook');
      final db = (txn as SembastTransaction).db;
      // Find existing book by businessIds
      final booksResult = await getBooks();
      if (booksResult.isLeft()) {
        throw booksResult.getLeft().getOrElse(
          () => DatabaseFailure('Failed to get books'),
        );
      }
      final projections = booksResult.getRight().getOrElse(() => []);
      final existingProjection = projections
          .where(
            (p) =>
                BookIdPairs(pairs: p.book.businessIds) ==
                BookIdPairs(pairs: book.businessIds),
          )
          .firstOrNull;
      if (existingProjection != null) {
        logger?.info('Unregistering old book ID pairs');
        final unregisterResult = _idRegistryService.unregisterBookIdPairs(
          BookIdPairs(pairs: existingProjection.book.businessIds),
        );
        if (unregisterResult.isLeft()) {
          throw unregisterResult.getLeft().getOrElse(
            () => RegistryFailure('Unregister ID pairs failed'),
          );
        }
        // Remove from old tags
        final oldTagNames = existingProjection.book.tags
            .map((t) => t.name)
            .toList();
        final removeResult = await _tagDatasource.removeBookFromTags(
          existingProjection.handle.toString(),
          oldTagNames,
          db: db,
        );
        if (removeResult.isLeft()) {
          throw removeResult.getLeft().getOrElse(
            () => DatabaseFailure('Remove relationships failed'),
          );
        }
      }
      final model = BookModel.fromEntity(
        book,
        existingProjection?.handle.toString() ??
            BookHandle.generate().toString(),
      );
      logger?.info('Saving updated book ${book.title}');
      final saveResult = await _bookDatasource.saveBook(model, db: db);
      if (saveResult.isLeft()) {
        throw saveResult.getLeft().getOrElse(
          () => DatabaseFailure('Save failed'),
        );
      }
      logger?.info('Registering new book ID pairs');
      final registerResult = _idRegistryService.registerBookIdPairs(
        BookIdPairs(pairs: book.businessIds),
      );
      if (registerResult.isLeft()) {
        throw registerResult.getLeft().getOrElse(
          () => RegistryFailure('Register ID pairs failed'),
        );
      }
      logger?.info('ID pairs registered, adding to new tags');
      final newTagNames = book.tags.map((t) => t.name).toList();
      final addResult = await _tagDatasource.addBookToTags(
        model.id,
        newTagNames,
        db: db,
      );
      if (addResult.isLeft()) {
        throw addResult.getLeft().getOrElse(
          () => DatabaseFailure('Add relationships failed'),
        );
      }
      logger?.info('Transaction operation completed for updateBook');
      return unit;
    });
  }

  /// Deletes a book from the database.
  @override
  Future<Either<Failure, Unit>> deleteBook({required Book book}) async {
    logger?.info('Entering deleteBook with book: ${book.title}');
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for deleteBook');
      final db = (txn as SembastTransaction).db;
      // Find the handle
      final booksResult = await getBooks();
      if (booksResult.isLeft()) {
        throw booksResult.getLeft().getOrElse(
          () => DatabaseFailure('Failed to get books'),
        );
      }
      final projections = booksResult.getRight().getOrElse(() => []);
      final projection = projections
          .where(
            (p) =>
                BookIdPairs(pairs: p.book.businessIds) ==
                BookIdPairs(pairs: book.businessIds),
          )
          .firstOrNull;
      if (projection == null) {
        throw NotFoundFailure('Book not found');
      }
      logger?.info('Unregistering book ID pairs');
      final unregisterResult = _idRegistryService.unregisterBookIdPairs(
        BookIdPairs(pairs: book.businessIds),
      );
      if (unregisterResult.isLeft()) {
        throw unregisterResult.getLeft().getOrElse(
          () => RegistryFailure('Unregister ID pairs failed'),
        );
      }
      logger?.info('Deleting book record');
      final deleteResult = await _bookDatasource.deleteBook(
        projection.handle.toString(),
        db: db,
      );
      if (deleteResult.isLeft()) {
        throw deleteResult.getLeft().getOrElse(
          () => DatabaseFailure('Delete failed'),
        );
      }
      logger?.info('Removing from tags');
      final tagNames = book.tags.map((t) => t.name).toList();
      final updateResult = await _tagDatasource.removeBookFromTags(
        projection.handle.toString(),
        tagNames,
        db: db,
      );
      if (updateResult.isLeft()) {
        throw updateResult.getLeft().getOrElse(
          () => DatabaseFailure('Update relationships failed'),
        );
      }
      logger?.info('Transaction operation completed for deleteBook');
      return unit;
    });
  }

  /// Retrieves books by a specific author.
  @override
  Future<Either<Failure, List<Book>>> getBooksByAuthor({
    required Author author,
  }) async {
    logger?.info('Entering getBooksByAuthor with author: ${author.name}');
    final booksResult = await getBooks();
    return booksResult.fold((failure) => Either.left(failure), (projections) {
      final books = projections
          .map((p) => p.book)
          .where((book) => book.authors.any((a) => a.name == author.name))
          .toList();
      logger?.info('Found ${books.length} books for author ${author.name}');
      return Either.right(books);
    });
  }

  /// Retrieves books by a specific tag.
  @override
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag}) async {
    logger?.info('Entering getBooksByTag with tag: ${tag.name}');
    final booksResult = await getBooks();
    return booksResult.fold((failure) => Either.left(failure), (projections) {
      final books = projections
          .map((p) => p.book)
          .where((book) => book.tags.any((t) => t.name == tag.name))
          .toList();
      logger?.info('Found ${books.length} books for tag ${tag.name}');
      return Either.right(books);
    });
  }

  /// Retrieves a book by its ID pairs.
  @override
  Future<Either<Failure, Book>> getBookById({
    required BookIdPairs bookId,
  }) async {
    logger?.info('Entering getBookById with bookId: $bookId');
    final booksResult = await getBooks();
    return booksResult.fold((failure) => Either.left(failure), (projections) {
      final book = projections
          .map((p) => p.book)
          .where((b) => BookIdPairs(pairs: b.businessIds) == bookId)
          .firstOrNull;
      if (book == null) {
        logger?.info('Book with id $bookId not found');
        return Either.left(NotFoundFailure('Book not found'));
      }
      logger?.info('Output: ${book.title}');
      return Either.right(book);
    });
  }
}
