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
    database = SembastDatabase(testDbPath: p.join('build', 'book_test'));
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('Book Integration Tests', () {
    test(
      'Comprehensive Book Integration Test',
      () async {
        final logger = SimpleLoggerImpl(name: 'BookTest');
        logger.info('Starting comprehensive test');

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

        final getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);
        final getByIdPairUsecase = GetBookByIdPairUsecase(
          bookRepository: bookRepository,
        );
        final addBookUsecase = AddBookUsecase(
          bookRepository: bookRepository,
          isBookDuplicateUsecase: IsBookDuplicateUsecase(),
        );
        final updateBookUsecase = UpdateBookUsecase(
          bookRepository: bookRepository,
        );
        final deleteBookUsecase = DeleteBookUsecase(
          bookRepository: bookRepository,
        );
        final authorRepository = AuthorRepositoryImpl(
          authorDatasource: authorDatasource,
          unitOfWork: unitOfWork,
        );
        final addAuthorUsecase = AddAuthorUsecase(
          authorRepository: authorRepository,
          idRegistryService: authorIdRegistryService,
        );
        final getAuthorsUsecase = GetAuthorsUsecase(
          authorRepository: authorRepository,
        );
        final TagRepository tagRepository;
        tagRepository = TagRepositoryImpl(
          tagDatasource: tagDatasource,

          unitOfWork: unitOfWork,
        );
        final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);

        // Check for zero records
        var result = await getBooksUsecase();
        expect(result.isRight(), true);
        var books = result.fold((l) => [], (r) => r);
        expect(books.isEmpty, true);

        // Add one record
        await addAuthorUsecase.call(name: 'Test Author');
        final authorsResult = await getAuthorsUsecase();
        expect(authorsResult.isRight(), true);
        final List<Author> authors = authorsResult.fold((l) => [], (r) => r);
        final newAuthor = authors.first;
        final newTag = Tag(id: const Uuid().v4(), name: 'Test Tag');
        await addTagUsecase.call(tag: newTag);

        final newBook = Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: "12345")],
          title: 'New Test Book',
          authors: [newAuthor],
          tags: [newTag],
          publishedDate: DateTime(2023, 1, 1),
        );
        await addBookUsecase.call(book: newBook);

        // Verify count
        result = await getBooksUsecase();
        expect(result.isRight(), true);
        books = result.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.title, 'New Test Book');
        expect(books.first.authors.first.name, 'Test Author');
        expect(books.first.tags.first.name, 'Test Tag');

        // Edit the record
        final updatedBook = newBook.copyWith(title: 'Updated Test Book');
        await updateBookUsecase.call(book: updatedBook);

        // Verify count remains the same
        result = await getBooksUsecase();
        expect(result.isRight(), true);
        books = result.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.title, 'Updated Test Book');

        // Get book by id pair
        var bookResult = await getByIdPairUsecase(
          bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "12345"),
        );
        expect(bookResult.isRight(), true);
        var book = bookResult.fold<Book?>((l) => null, (r) => r);
        expect(book, isNotNull);
        expect(book!.title, 'Updated Test Book');

        // Add another record
        await addAuthorUsecase.call(name: 'Second Author');
        final authorsResult2 = await getAuthorsUsecase();
        expect(authorsResult2.isRight(), true);
        final List<Author> authors2 = authorsResult2.fold((l) => [], (r) => r);

        final secondAuthor = authors2.firstWhere(
          (a) => a.name == 'Second Author',
        );
        final secondTag = Tag(id: const Uuid().v4(), name: 'Second Tag');
        await addTagUsecase.call(tag: secondTag);

        final secondBook = Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: "67890")],
          title: 'Second Test Book',
          authors: [secondAuthor],
          tags: [secondTag],
          publishedDate: DateTime(2023, 2, 1),
        );
        await addBookUsecase.call(book: secondBook);

        // Verify count increases
        result = await getBooksUsecase();
        expect(result.isRight(), true);
        books = result.fold((l) => [], (r) => r);
        expect(books.length, 2);

        // Delete one record
        await deleteBookUsecase.call(
          bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "12345"),
        );

        // Verify count decreases
        result = await getBooksUsecase();
        expect(result.isRight(), true);
        books = result.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.title, 'Second Test Book');

        // Update the remaining book
        final finalUpdatedBook = secondBook.copyWith(
          title: 'Final Updated Book',
        );
        await updateBookUsecase.call(book: finalUpdatedBook);

        // Verify update
        bookResult = await getByIdPairUsecase(
          bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "67890"),
        );
        expect(bookResult.isRight(), true);
        book = bookResult.fold<Book?>((l) => null, (r) => r);
        expect(book, isNotNull);
        expect(book!.title, 'Final Updated Book');

        // Delete the last book
        await deleteBookUsecase.call(
          bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "67890"),
        );

        // Verify zero records
        result = await getBooksUsecase();
        expect(result.isRight(), true);
        books = result.fold((l) => [], (r) => r);
        expect(books.isEmpty, true);

        // Close database
        logger.info('Closing database');
        await database.close();
        logger.info('Test completed');
      },
      timeout: Timeout(Duration(seconds: 60)),
    );
  });
}
