import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';

import '../isar/datasources/author_datasource.dart';
import '../isar/datasources/book_datasource.dart';
import '../isar/datasources/tag_datasource.dart';
import '../models/book_model.dart';
import 'base_repository.dart';

/// Isar implementation of [BookRepository].
class BookRepositoryImpl extends IsarBaseRepository
    with Loggable
    implements BookRepository {
  final BookDatasource _bookDatasource;
  final AuthorDatasource _authorDatasource;
  final TagDatasource _tagDatasource;
  final BookIdRegistryService _idRegistryService;

  BookRepositoryImpl({
    required BookDatasource bookDatasource,
    required AuthorDatasource authorDatasource,
    required TagDatasource tagDatasource,
    required BookIdRegistryService idRegistryService,
    required UnitOfWork<TransactionHandle> unitOfWork,
    Logger? logger,
  }) : _bookDatasource = bookDatasource,
       _authorDatasource = authorDatasource,
       _tagDatasource = tagDatasource,
       _idRegistryService = idRegistryService,
       super(unitOfWork) {
    this.logger = logger;
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  @override
  TaskEither<Failure, List<Book>> getAll() => getBooks();

  @override
  TaskEither<Failure, List<Book>> getBooks({int? limit, int? offset}) =>
      _bookDatasource.getAllBooks().flatMap(
        (models) => TaskEither.traverseList(models, _loadBookWithRelations),
      );

  @override
  TaskEither<Failure, List<Book>> listSection({int? limit, int? offset}) =>
      getBooks(limit: limit, offset: offset);

  @override
  TaskEither<Failure, Book> getById({required String id}) =>
      _bookDatasource.getBookById(id).flatMap(
        (model) => model != null
            ? _loadBookWithRelations(model)
            : TaskEither.left(NotFoundFailure('Book not found')),
      );

  @override
  TaskEither<Failure, Book> getBookByIdPair({required BookIdPair bookIdPair}) =>
      _bookDatasource.getBooksByBusinessIdPair(bookIdPair).flatMap(
        (models) => models.isNotEmpty
            ? _loadBookWithRelations(models.first)
            : TaskEither.left(NotFoundFailure('Book not found')),
      );

  @override
  TaskEither<Failure, Book> getBookByBusinessIds({
    required BookIdPairs bookId,
  }) => _bookDatasource.getBookByBusinessIds(bookId.idPairs).flatMap(
    (model) => model != null
        ? _loadBookWithRelations(model)
        : TaskEither.left(NotFoundFailure('Book not found')),
  );

  @override
  TaskEither<Failure, List<Book>> getBooksByAuthor({required Author author}) =>
      _bookDatasource.getBooksByAuthorId(author.id).flatMap(
        (models) => TaskEither.traverseList(models, _loadBookWithRelations),
      );

  @override
  TaskEither<Failure, List<Book>> getBooksByTag({required Tag tag}) =>
      _tagDatasource.getTagById(tag.id).flatMap(
        (tagModel) => tagModel != null
            ? TaskEither.traverseList(
                tagModel.bookIds,
                (bookId) => getById(id: bookId),
              )
            : TaskEither.left(NotFoundFailure('Tag not found')),
      );

  // ─── Write operations ─────────────────────────────────────────────────────

  @override
  TaskEither<Failure, Book> create({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final book =
        item.id.isNotEmpty ? item : item.copyWith(id: const Uuid().v4());
    final model = BookModel.fromEntity(book);

    return runInTransaction(
      txn: txn,
      operation: (_) =>
          _idRegistryService
              .registerBookIdPairs(BookIdPairs(pairs: book.businessIds))
              .flatMap((_) => _bookDatasource.saveBook(model))
              .flatMap(
                (_) => _tagDatasource.addBookToTags(
                  book.id,
                  book.tags.map((t) => t.name).toList(),
                ),
              )
              .map((_) => book),
    );
  }

  @override
  TaskEither<Failure, Book> update({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final model = BookModel.fromEntity(item);
    return runInTransaction(
      txn: txn,
      operation: (_) =>
          _bookDatasource.saveBook(model).map((_) => item),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteById({
    required Book item,
    UnitOfWork<TransactionHandle>? txn,
  }) => runInTransaction(
    txn: txn,
    operation: (_) =>
        _idRegistryService
            .unregisterBookIdPairs(BookIdPairs(pairs: item.businessIds))
            .flatMap((_) => _bookDatasource.deleteBook(item.id))
            .flatMap(
              (_) => _tagDatasource.removeBookFromTags(
                item.id,
                item.tags.map((t) => t.name).toList(),
              ),
            )
            .map((_) => unit),
  );

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) =>
      runInTransaction(
        txn: txn,
        operation: (_) => _bookDatasource.deleteAll(),
      );

  // ─── Private helpers ──────────────────────────────────────────────────────

  TaskEither<Failure, Book> _loadBookWithRelations(BookModel model) {
    final loadAuthors = TaskEither.traverseList(
      model.authorIds,
      (id) => _authorDatasource.getAuthorById(id).map((m) => m?.toEntity()),
    ).map((authors) => authors.whereType<Author>().toList());

    final loadTags = TaskEither.traverseList(
      model.tagIds,
      (id) => _tagDatasource.getTagById(id).map((m) => m?.toEntity()),
    ).map((tags) => tags.whereType<Tag>().toList());

    return loadAuthors.flatMap(
      (authors) => loadTags.map(
        (tags) => model.toEntity(authors: authors, tags: tags),
      ),
    );
  }
}
