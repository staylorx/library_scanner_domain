import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseService database;
  late TagDatasource tagDatasource;
  late BookDatasource bookDatasource;
  late AuthorDatasource authorDatasource;

  setUpAll(() async {
    database = SembastDatabase(
      testDbPath: p.join('build', 'book_repository_test_${const Uuid().v4()}'),
    );
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('BookRepository Integration Tests', () {
    test('BookRepository CRUD operations', () async {
      final logger = SimpleLoggerImpl(name: 'BookRepositoryTest');
      logger.info('Starting BookRepository test');

      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');

      final authorIdRegistryService = AuthorIdRegistryServiceImpl();
      final bookIdRegistryService = BookIdRegistryServiceImpl();
      final unitOfWork = SembastUnitOfWork(dbService: database);
      final bookRepository = BookRepositoryImpl(
        authorDatasource: authorDatasource,
        tagDatasource: tagDatasource,
        bookDatasource: bookDatasource,
        idRegistryService: bookIdRegistryService,
        unitOfWork: unitOfWork,
      );

      final authorRepository = AuthorRepositoryImpl(
        authorDatasource: authorDatasource,
        unitOfWork: unitOfWork,
        idRegistryService: authorIdRegistryService,
      );
      final tagRepository = TagRepositoryImpl(
        tagDatasource: tagDatasource,
        unitOfWork: unitOfWork,
      );

      // Set up authors and tags via repositories
      final author = Author(
        id: const Uuid().v4(),
        businessIds: [
          AuthorIdPair(idType: AuthorIdType.local, idCode: "author1"),
        ],
        name: 'Test Author',
        biography: 'Test bio',
      );
      await authorRepository.addAuthor(author: author);

      final tag = Tag(
        id: const Uuid().v4(),
        name: 'Test Tag',
        description: 'Test description',
        color: '#FF0000',
      );
      await tagRepository.addTag(tag: tag);

      // Check for zero books
      var booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      var books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.isEmpty, true);

      // Add one book
      final newBook = Book(
        id: const Uuid().v4(),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "12345")],
        title: 'New Test Book',
        authors: [author],
        tags: [tag],
        publishedDate: DateTime(2023, 1, 1),
        description: 'Test description',
        coverImage: null,
        notes: null,
      );
      await bookRepository.addBook(book: newBook);

      // Verify count
      booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.length, 1);
      expect(books.first.title, 'New Test Book');
      expect(books.first.authors.first.name, 'Test Author');
      expect(books.first.tags.first.name, 'Test Tag');

      // Update the book
      final updatedBook = books.first.copyWith(title: 'Updated Test Book');
      await bookRepository.updateBook(book: updatedBook);

      // Verify update
      booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.length, 1);
      expect(books.first.title, 'Updated Test Book');

      // Get book by id pair
      var bookResult = await bookRepository.getBookByIdPair(
        bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "12345"),
      );
      expect(bookResult.isRight(), true);
      var book = bookResult.fold<Book?>((l) => null, (r) => r);
      expect(book, isNotNull);
      expect(book!.title, 'Updated Test Book');

      // Add another book
      final secondAuthor = Author(
        id: const Uuid().v4(),
        businessIds: [
          AuthorIdPair(idType: AuthorIdType.local, idCode: "author2"),
        ],
        name: 'Second Author',
      );
      await authorRepository.addAuthor(author: secondAuthor);

      final secondTag = Tag(id: const Uuid().v4(), name: 'Second Tag');
      await tagRepository.addTag(tag: secondTag);

      final secondBook = Book(
        id: const Uuid().v4(),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "67890")],
        title: 'Second Test Book',
        authors: [secondAuthor],
        tags: [secondTag],
        publishedDate: DateTime(2023, 2, 1),
      );
      await bookRepository.addBook(book: secondBook);

      // Verify count increases
      booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.length, 2);

      // Test getBooksByAuthor
      var booksByAuthor = await bookRepository.getBooksByAuthor(author: author);
      expect(booksByAuthor.isRight(), true);
      var authorBooks = booksByAuthor.getRight().getOrElse(() => []);
      expect(authorBooks.length, 1);
      expect(authorBooks.first.title, 'Updated Test Book');

      // Test getBooksByTag
      var booksByTag = await bookRepository.getBooksByTag(tag: tag);
      expect(booksByTag.isRight(), true);
      var tagBooks = booksByTag.getRight().getOrElse(() => []);
      expect(tagBooks.length, 1);
      expect(tagBooks.first.title, 'Updated Test Book');

      // Delete one book
      await bookRepository.deleteBook(book: updatedBook);

      // Verify count decreases
      booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.length, 1);
      expect(books.first.title, 'Second Test Book');

      // Delete the last book
      await bookRepository.deleteBook(book: secondBook);

      // Verify zero books
      booksEither = await bookRepository.getBooks();
      expect(booksEither.isRight(), true);
      books = booksEither.getRight().getOrElse(() => <Book>[]);
      expect(books.isEmpty, true);

      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
