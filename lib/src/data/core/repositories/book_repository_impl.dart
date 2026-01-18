import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

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
  Future<Either<Failure, List<Book>>> getBooks({
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
    final books = <Book>[];
    for (final model in models) {
      final book = await _loadBookWithRelations(model);
      books.add(book);
    }
    logger?.info('Successfully retrieved ${books.length} books');
    return Either.right(books);
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

  /// Retrieves a book by its id.
  @override
  Future<Either<Failure, Book>> getBookById({required String id}) async {
    logger?.info('Entering getById with id: $id');
    final result = await _bookDatasource.getBookById(id);
    if (result.isLeft()) {
      final failure = result.getLeft().getOrElse(
        () => DatabaseFailure('Failed to get book'),
      );
      logger?.warning(
        'Failed to get book by id: $id, Error: ${failure.message}',
      );
      return Either.left(failure);
    }
    final model = result.getRight().getOrElse(() => null);
    if (model == null) {
      logger?.info('Book with id $id not found');
      return Either.left(NotFoundFailure('Book not found'));
    }
    final book = await _loadBookWithRelations(model);
    logger?.info('Output: ${book.title}');
    return Either.right(book);
  }

  /// Retrieves a book by its ID pair.
  @override
  Future<Either<Failure, Book>> getBookByIdPair({
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

  /// Adds a new book to the database.
  @override
  Future<Either<Failure, Book>> addBook({
    required Book book,
    Transaction? txn,
  }) async {
    logger?.info('Entering addBook with book: ${book.title}, id: ${book.id}');
    final bookWithId = book.id.isNotEmpty
        ? book
        : book.copyWith(id: const Uuid().v4());
    final model = BookModel.fromEntity(bookWithId);
    if (txn != null) {
      logger?.info('Using provided transaction for addBook');
      final saveResult = await _bookDatasource.saveBook(model, txn: txn);
      if (saveResult.isLeft()) {
        return Either.left(
          saveResult.getLeft().getOrElse(() => DatabaseFailure('Save failed')),
        );
      }
      logger?.info('Book saved, registering ID pairs');
      final registerResult = _idRegistryService.registerBookIdPairs(
        BookIdPairs(pairs: book.businessIds),
      );
      if (registerResult.isLeft()) {
        return Either.left(
          registerResult.getLeft().getOrElse(
            () => RegistryFailure('Register ID pairs failed'),
          ),
        );
      }
      logger?.info('ID pairs registered, updating relationships');
      final tagNames = book.tags.map((t) => t.name).toList();
      final updateResult = await _tagDatasource.addBookToTags(
        bookWithId.id,
        tagNames,
        txn: txn,
      );
      return updateResult.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(bookWithId),
      );
    } else {
      return _unitOfWork.run((Transaction txn) async {
        logger?.info('Transaction started for addBook');
        final saveResult = await _bookDatasource.saveBook(model, txn: txn);
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
          bookWithId.id,
          tagNames,
          txn: txn,
        );
        if (updateResult.isLeft()) {
          throw updateResult.getLeft().getOrElse(
            () => DatabaseFailure('Update relationships failed'),
          );
        }
        logger?.info('Transaction operation completed for addBook');
        return bookWithId;
      });
    }
  }

  /// Updates an existing book in the database.
  @override
  Future<Either<Failure, Unit>> updateBook({
    required Book book,
    Transaction? txn,
  }) async {
    logger?.info('Entering updateBook with book: ${book.title}');
    final model = BookModel.fromEntity(book);
    if (txn != null) {
      logger?.info('Using provided transaction for updateBook');
      final saveResult = await _bookDatasource.saveBook(model, txn: txn);
      return saveResult.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } else {
      return _unitOfWork.run((Transaction txn) async {
        logger?.info('Transaction started for updateBook');
        final saveResult = await _bookDatasource.saveBook(model, txn: txn);
        if (saveResult.isLeft()) {
          throw saveResult.getLeft().getOrElse(
            () => DatabaseFailure('Save failed'),
          );
        }
        logger?.info('Transaction operation completed for updateBook');
        return unit;
      });
    }
  }

  /// Deletes a book from the database.
  @override
  Future<Either<Failure, Unit>> deleteBook({
    required Book book,
    Transaction? txn,
  }) async {
    logger?.info('Entering deleteBook with book: ${book.title}');

    if (txn != null) {
      logger?.info('Using provided transaction for deleteBook');
      logger?.info('Unregistering book ID pairs');
      final unregisterResult = _idRegistryService.unregisterBookIdPairs(
        BookIdPairs(pairs: book.businessIds),
      );
      if (unregisterResult.isLeft()) {
        return Either.left(
          unregisterResult.getLeft().getOrElse(
            () => RegistryFailure('Unregister ID pairs failed'),
          ),
        );
      }
      logger?.info('Deleting book record');
      final deleteResult = await _bookDatasource.deleteBook(book.id, txn: txn);
      if (deleteResult.isLeft()) {
        return Either.left(
          deleteResult.getLeft().getOrElse(
            () => DatabaseFailure('Delete failed'),
          ),
        );
      }
      logger?.info('Removing from tags');
      final tagNames = book.tags.map((t) => t.name).toList();
      final updateResult = await _tagDatasource.removeBookFromTags(
        book.id,
        tagNames,
        txn: txn,
      );
      return updateResult.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } else {
      return _unitOfWork.run((Transaction txn) async {
        logger?.info('Transaction started for deleteBook');
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
          book.id,
          txn: txn,
        );
        if (deleteResult.isLeft()) {
          throw deleteResult.getLeft().getOrElse(
            () => DatabaseFailure('Delete failed'),
          );
        }
        logger?.info('Removing from tags');
        final tagNames = book.tags.map((t) => t.name).toList();
        final updateResult = await _tagDatasource.removeBookFromTags(
          book.id,
          tagNames,
          txn: txn,
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
  }

  /// Retrieves books by a specific author.
  @override
  Future<Either<Failure, List<Book>>> getBooksByAuthor({
    required Author author,
  }) async {
    logger?.info('Entering getBooksByAuthor with author: ${author.name}');
    final result = await _bookDatasource.getBooksByAuthorId(author.id);
    return result.fold((failure) => Either.left(failure), (models) async {
      final books = <Book>[];
      for (final model in models) {
        final book = await _loadBookWithRelations(model);
        books.add(book);
      }
      logger?.info('Found ${books.length} books for author ${author.name}');
      return Either.right(books);
    });
  }

  /// Retrieves books by a specific tag.
  @override
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag}) async {
    logger?.info('Entering getBooksByTag with tag: ${tag.name}');
    final result = await _bookDatasource.getBooksByTagId(tag.id);
    return result.fold((failure) => Either.left(failure), (models) async {
      final books = <Book>[];
      for (final model in models) {
        final book = await _loadBookWithRelations(model);
        books.add(book);
      }
      logger?.info('Found ${books.length} books for tag ${tag.name}');
      return Either.right(books);
    });
  }

  /// Retrieves a book by its business ID pairs.
  @override
  Future<Either<Failure, Book>> getBookByBusinessIds({
    required BookIdPairs bookId,
  }) async {
    logger?.info('Entering getBookByBusinessIds with bookId: $bookId');
    final result = await _bookDatasource.getBookByBusinessIds(bookId.idPairs);
    return result.fold((failure) => Either.left(failure), (model) async {
      if (model == null) {
        logger?.info('Book with business ids $bookId not found');
        return Either.left(NotFoundFailure('Book not found'));
      }
      final book = await _loadBookWithRelations(model);
      logger?.info('Output: ${book.title}');
      return Either.right(book);
    });
  }
}
