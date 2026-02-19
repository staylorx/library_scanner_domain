import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';
import 'package:sembast/sembast.dart' as sembast;
import '../sembast/datasources/book_datasource.dart';
import '../sembast/datasources/author_datasource.dart';
import '../sembast/datasources/tag_datasource.dart';
import '../models/book_model.dart';

/// Implementation of book repository using Sembast.
class BookRepositoryImpl with Loggable implements BookRepository {
  final BookDatasource bookDatasource;
  final AuthorDatasource authorDatasource;
  final TagDatasource tagDatasource;
  final BookIdRegistryService idRegistryService;
  final UnitOfWork<Object?> unitOfWork;

  /// Creates a BookRepositoryImpl instance.
  BookRepositoryImpl({
    required this.bookDatasource,
    required this.authorDatasource,
    required this.tagDatasource,
    required this.idRegistryService,
    required this.unitOfWork,
    Logger? logger,
  });

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
  TaskEither<Failure, Book> create({required Book item, UnitOfWork<Object?>? txn}) {
    final book = item;
    logger?.info(
      'Entering createBook with book: ${book.title}, id: ${book.id}',
    );
    final bookWithId = book.id.isNotEmpty
        ? book
        : book.copyWith(id: const Uuid().v4());
    final model = BookModel.fromEntity(bookWithId);
    final UnitOfWork<Object?> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run(
      (UnitOfWork<Object?> t) => bookDatasource
          .saveBook(model, txn: t.transactionHandle as sembast.DatabaseClient?)
          .map((_) => unit)
          .flatMap(
            (_) => idRegistryService.registerBookIdPairs(
              BookIdPairs(pairs: book.businessIds),
            ),
          )
          .flatMap(
            (_) => tagDatasource
                .addBookToTags(
                  bookWithId.id,
                  book.tags.map((t) => t.name).toList(),
                   txn: t.transactionHandle as sembast.DatabaseClient?,
                )
                .map((_) => bookWithId),
          ),
    );
  }

  /// Updates an existing book in the database and returns the updated book.
  @override
  TaskEither<Failure, Book> update({required Book item, UnitOfWork<Object?>? txn}) {
    final book = item;
    logger?.info('Entering updateBook with book: ${book.title}');
    final model = BookModel.fromEntity(book);
    final UnitOfWork<Object?> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run((UnitOfWork<Object?> t) =>
        bookDatasource.saveBook(model, txn: t.transactionHandle as sembast.DatabaseClient?).map((_) => book));
  }

  /// Deletes a book from the database.
  @override
  TaskEither<Failure, Unit> deleteById({required Book item, UnitOfWork<Object?>? txn}) {
    final book = item;
    logger?.info('Entering deleteBook with book: ${book.title}');

    final UnitOfWork<Object?> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run((UnitOfWork<Object?> t) => idRegistryService
        .unregisterBookIdPairs(BookIdPairs(pairs: book.businessIds))
        .flatMap((_) => bookDatasource.deleteBook(book.id, txn: t.transactionHandle as sembast.DatabaseClient?))
        .flatMap((_) {
          final tagNames = book.tags.map((t) => t.name).toList();
          return tagDatasource.removeBookFromTags(book.id, tagNames, txn: t.transactionHandle as sembast.DatabaseClient?);
        }));
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
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<Object?>? txn}) {
    throw UnimplementedError();
  }
}
