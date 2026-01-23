import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

/// Implementation of book repository using Sembast.
class BookRepositoryImpl with Loggable implements BookRepository {
  final BookDatasource bookDatasource;
  final AuthorDatasource authorDatasource;
  final TagDatasource tagDatasource;
  final BookIdRegistryService idRegistryService;
  final UnitOfWork unitOfWork;

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
  TaskEither<Failure, Book> getBookById({required String id}) {
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

  /// Adds a new book to the database.
  @override
  TaskEither<Failure, Book> addBook({required Book book, Transaction? txn}) {
    logger?.info('Entering addBook with book: ${book.title}, id: ${book.id}');
    final bookWithId = book.id.isNotEmpty
        ? book
        : book.copyWith(id: const Uuid().v4());
    final model = BookModel.fromEntity(bookWithId);
    if (txn != null) {
      logger?.info('Using provided transaction for addBook');
      return bookDatasource.saveBook(model, txn: txn)
          .map((_) => unit)
          .flatMap(
            (_) => idRegistryService.registerBookIdPairs(
              BookIdPairs(pairs: book.businessIds),
            ),
          )
          .flatMap(
            (_) => tagDatasource
                .addBookToTags(bookWithId.id, book.tags.map((t) => t.name).toList(), txn: txn)
                .map((_) => bookWithId),
          );
    } else {
      return unitOfWork.run(
        (Transaction txn) =>
            TaskEither.tryCatch(() async {
                  logger?.info('Transaction started for addBook');
                  final either = await bookDatasource
                      .saveBook(model, txn: txn)
                      .run();
                  return either.fold((l) => throw l, (_) => unit);
                }, (e, _) => e as Failure)
                .flatMap(
                  (_) => idRegistryService.registerBookIdPairs(
                    BookIdPairs(pairs: book.businessIds),
                  ),
                )
                .flatMap(
                  (_) => TaskEither.tryCatch(() async {
                    logger?.info('ID pairs registered, updating relationships');
                    final tagNames = book.tags.map((t) => t.name).toList();
                    final either = await tagDatasource
                        .addBookToTags(bookWithId.id, tagNames, txn: txn)
                        .run();
                    return either.fold((l) => throw l, (_) => bookWithId);
                  }, (e, _) => e as Failure),
                ),
      );
    }
  }

  /// Updates an existing book in the database.
  @override
  TaskEither<Failure, Unit> updateBook({required Book book, Transaction? txn}) {
    logger?.info('Entering updateBook with book: ${book.title}');
    final model = BookModel.fromEntity(book);
    if (txn != null) {
      logger?.info('Using provided transaction for updateBook');
      return TaskEither.tryCatch(() async {
        final either = await bookDatasource.saveBook(model, txn: txn).run();
        return either.fold((l) => throw l, (_) => unit);
      }, (e, _) => e as Failure);
    } else {
      return unitOfWork.run(
        (Transaction txn) => TaskEither.tryCatch(() async {
          logger?.info('Transaction started for updateBook');
          final either = await bookDatasource.saveBook(model, txn: txn).run();
          return either.fold((l) => throw l, (_) => unit);
        }, (e, _) => e as Failure),
      );
    }
  }

  /// Deletes a book from the database.
  @override
  TaskEither<Failure, Unit> deleteBook({required Book book, Transaction? txn}) {
    logger?.info('Entering deleteBook with book: ${book.title}');

    if (txn != null) {
      logger?.info('Using provided transaction for deleteBook');
      return idRegistryService
          .unregisterBookIdPairs(BookIdPairs(pairs: book.businessIds))
          .flatMap(
            (_) => TaskEither.tryCatch(() async {
              logger?.info('Deleting book record');
              final either = await bookDatasource
                  .deleteBook(book.id, txn: txn)
                  .run();
              return either.fold((l) => throw l, (_) => unit);
            }, (e, _) => e as Failure),
          )
          .flatMap(
            (_) => TaskEither.tryCatch(() async {
              logger?.info('Removing from tags');
              final tagNames = book.tags.map((t) => t.name).toList();
              final either = await tagDatasource
                  .removeBookFromTags(book.id, tagNames, txn: txn)
                  .run();
              return either.fold((l) => throw l, (_) => unit);
            }, (e, _) => e as Failure),
          );
    } else {
      return unitOfWork.run(
        (Transaction txn) => idRegistryService
            .unregisterBookIdPairs(BookIdPairs(pairs: book.businessIds))
            .flatMap(
              (_) => TaskEither.tryCatch(() async {
                logger?.info('Transaction started for deleteBook');
                logger?.info('Deleting book record');
                final either = await bookDatasource
                    .deleteBook(book.id, txn: txn)
                    .run();
                return either.fold((l) => throw l, (_) => unit);
              }, (e, _) => e as Failure),
            )
            .flatMap(
              (_) => TaskEither.tryCatch(() async {
                logger?.info('Removing from tags');
                final tagNames = book.tags.map((t) => t.name).toList();
                final either = await tagDatasource
                    .removeBookFromTags(book.id, tagNames, txn: txn)
                    .run();
                return either.fold((l) => throw l, (_) => unit);
              }, (e, _) => e as Failure),
            ),
      );
    }
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
        (bookId) => getBookById(id: bookId),
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
}
