import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_entities/src/utils/transaction_handle.dart';


import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';
import '../sembast/datasources/book_datasource.dart';
import '../sembast/datasources/author_datasource.dart';
import '../sembast/datasources/tag_datasource.dart';
import '../models/book_model.dart';

import 'base_repository.dart';

/// Implementation of book repository using Sembast.
class BookRepositoryImpl extends SembastBaseRepository with Loggable implements BookRepository {
  final BookDatasource bookDatasource;
  final AuthorDatasource authorDatasource;
  final TagDatasource tagDatasource;
  final BookIdRegistryService idRegistryService;

  /// Creates a BookRepositoryImpl instance.
  BookRepositoryImpl({
    required this.bookDatasource,
    required this.authorDatasource,
    required this.tagDatasource,
    required this.idRegistryService,
    required UnitOfWork<TransactionHandle> unitOfWork,
    Logger? logger,
  }) : super(unitOfWork) {
    this.logger = logger;
  }

  /// Retrieves books from the database.
  @override
  TaskEither<Failure, List<Book>> getBooks({int? limit, int? offset}) {
    logger?.info('Entering getBooks');
    return bookDatasource.getAllBooks().flatMap(
      (models) =>
          TaskEither.traverseList(models, _loadBookWithRelations).map((books) {
            logger?.info('Successfully retrieved ${books.length} books');
            return books;
          }),
    );
  }

  @override
  TaskEither<Failure, List<Book>> getAll() {
    return getBooks();
  }

  @override
  TaskEither<Failure, List<Book>> listSection({int? limit, int? offset}) {
    return getBooks(limit: limit, offset: offset);
  }

  TaskEither<Failure, Book> _loadBookWithRelations(BookModel model) {
    // Load authors
    final loadAuthors = TaskEither.traverseList(
      model.authorIds,
      (authorId) => authorDatasource
          .getAuthorById(authorId)
          .map((authorModel) => authorModel?.toEntity()),
    ).map((authors) => authors.whereType<Author>().toList());

    // Load tags
    final loadTags = TaskEither.traverseList(
      model.tagIds,
      (tagId) => tagDatasource
          .getTagById(tagId)
          .map((tagModel) => tagModel?.toEntity()),
    ).map((tags) => tags.whereType<Tag>().toList());

    return loadAuthors.flatMap(
      (authors) =>
          loadTags.map((tags) => model.toEntity(authors: authors, tags: tags)),
    );
  }

  /// Retrieves a book by its id.
  @override
  TaskEither<Failure, Book> getById({required String id}) {
    logger?.info('Entering getById with id: $id');
    return bookDatasource.getBookById(id).flatMap((model) {
      if (model == null) {
        logger?.info('Book with id $id not found');
        return TaskEither.left(NotFoundFailure('Book not found'));
      }
      return _loadBookWithRelations(model).map((book) {
        logger?.info('Output: ${book.title}');
        return book;
      });
    });
  }

  /// Retrieves a book by its ID pair.
  @override
  TaskEither<Failure, Book> getBookByIdPair({required BookIdPair bookIdPair}) {
    logger?.info('Entering getByIdPair with bookIdPair: $bookIdPair');
    return bookDatasource.getBooksByBusinessIdPair(bookIdPair).flatMap((
      models,
    ) {
      if (models.isEmpty) {
        logger?.debug('Book not found');
        return TaskEither.left(NotFoundFailure('Book not found'));
      }
      return _loadBookWithRelations(models.first).map((book) {
        logger?.debug('Output: ${book.title}');
        return book;
      });
    });
  }

  /// Creates a new book in the database.
  @override
  TaskEither<Failure, Book> create({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final book = item;
    logger?.info(
      'Entering createBook with book: ${book.title}, id: ${book.id}',
    );
    final bookWithId = book.id.isNotEmpty
        ? book
        : book.copyWith(id: const Uuid().v4());
    final model = BookModel.fromEntity(bookWithId);
    logger?.info('Transaction started for createBook');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => bookDatasource
          .saveBook(model, txn: dbClient)
          .map((_) => unit)
          .flatMap(
            (_) => idRegistryService.registerBookIdPairs(
              BookIdPairs(pairs: book.businessIds),
            ),
          )
          .flatMap(
            (_) => tagDatasource.addBookToTags(
              bookWithId.id,
              book.tags.map((t) => t.name).toList(),
              txn: dbClient,
            ).map((_) => bookWithId),
          ),
    );
  }

  /// Updates an existing book in the database and returns the updated book.
  @override
  TaskEither<Failure, Book> update({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final book = item;
    logger?.info('Entering updateBook with book: ${book.title}');
    final model = BookModel.fromEntity(book);
    logger?.info('Transaction started for updateBook');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => bookDatasource.saveBook(model, txn: dbClient).map((_) => book),
    );
  }

  /// Deletes a book from the database.
  @override
  TaskEither<Failure, Unit> deleteById({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final book = item;
    logger?.info('Entering deleteBook with book: ${book.title}');

    logger?.info('Transaction started for deleteBook');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => idRegistryService
          .unregisterBookIdPairs(BookIdPairs(pairs: book.businessIds))
          .flatMap(
            (_) => bookDatasource.deleteBook(book.id, txn: dbClient),
          )
          .flatMap((_) {
            final tagNames = book.tags.map((t) => t.name).toList();
            return tagDatasource.removeBookFromTags(book.id, tagNames, txn: dbClient);
          }),
    );
  }

  /// Retrieves books by a specific author.
  @override
  TaskEither<Failure, List<Book>> getBooksByAuthor({required Author author}) {
    logger?.info('Entering getBooksByAuthor with author: ${author.name}');
    return bookDatasource
        .getBooksByAuthorId(author.id)
        .flatMap(
          (models) => TaskEither.traverseList(models, _loadBookWithRelations)
              .map((books) {
                logger?.info(
                  'Found ${books.length} books for author ${author.name}',
                );
                return books;
              }),
        );
  }

  /// Retrieves books by a specific tag.
  @override
  TaskEither<Failure, List<Book>> getBooksByTag({required Tag tag}) {
    logger?.info('Entering getBooksByTag with tag: ${tag.name}');
    return tagDatasource.getTagById(tag.id).flatMap((tagModel) {
      if (tagModel == null) {
        logger?.info('Tag not found');
        return TaskEither.left(NotFoundFailure('Tag not found'));
      }
      final bookIds = tagModel.bookIds;
      return TaskEither.traverseList(
        bookIds,
        (bookId) => getById(id: bookId),
      ).map((books) {
        logger?.info('Found ${books.length} books for tag ${tag.name}');
        return books.whereType<Book>().toList();
      });
    });
  }

  /// Retrieves a book by its business ID pairs.
  @override
  TaskEither<Failure, Book> getBookByBusinessIds({
    required BookIdPairs bookId,
  }) {
    logger?.info('Entering getBookByBusinessIds with bookId: $bookId');
    return bookDatasource.getBookByBusinessIds(bookId.idPairs).flatMap((model) {
      if (model == null) {
        logger?.info('Book with business ids $bookId not found');
        return TaskEither.left(NotFoundFailure('Book not found'));
      }
      return _loadBookWithRelations(model).map((book) {
        logger?.info('Output: ${book.title}');
        return book;
      });
    });
  }

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) {
    throw UnimplementedError();
  }
}
