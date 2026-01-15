import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;

void main() {
  late DatabaseService database;
  late TagDatasource tagDatasource;
  late BookDatasource bookDatasource;
  late AuthorDatasource authorDatasource;

  setUpAll(() async {
    database = SembastDatabase(testDbPath: p.join('build', 'author_test'));
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('Author Integration Tests', () {
    test(
      'Comprehensive Author Integration Test',
      () async {
        final logger = SimpleLoggerImpl(name: 'AuthorTest');
        logger.logLevel = null;

        logger.info('Starting comprehensive test');

        logger.info('Database instance created');
        (await database.clearAll()).fold((l) => throw l, (r) => null);
        logger.info('Database cleared');

        final authorIdRegistryService = AuthorIdRegistryServiceImpl();
        final bookIdRegistryService = BookIdRegistryServiceImpl();
        final authorRepository = AuthorRepositoryImpl(
          authorDatasource: authorDatasource,
        );
        final bookRepository = BookRepositoryImpl(
          authorDatasource: authorDatasource,
          bookDatasource: bookDatasource,
          idRegistryService: bookIdRegistryService,
          tagDatasource: tagDatasource,
        );

        final getAuthorsUsecase = GetAuthorsUsecase(
          authorRepository: authorRepository,
        );
        final getAuthorByNameUsecase = GetAuthorByNameUsecase(
          logger: logger,
          authorRepository: authorRepository,
        );
        final addAuthorUsecase = AddAuthorUsecase(
          authorRepository: authorRepository,
          idRegistryService: authorIdRegistryService,
        );
        final updateAuthorUsecase = UpdateAuthorUsecase(
          authorRepository: authorRepository,
        );
        final deleteAuthorUsecase = DeleteAuthorUsecase(
          authorRepository: authorRepository,
        );
        final getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);
        final addBookUsecase = AddBookUsecase(
          bookRepository: bookRepository,
          isBookDuplicateUsecase: IsBookDuplicateUsecase(),
        );
        final tagRepository = TagRepositoryImpl(
          tagDatasource: tagDatasource,
          databaseService: database,
        );
        final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);

        // Check for zero records
        var result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        List<AuthorProjection> authors = result.fold((l) => [], (r) => r);
        expect(authors.isEmpty, true);

        // Add one record
        await addAuthorUsecase.call(name: 'Test Author');

        // Verify count
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.author.name, 'Test Author');
        final newAuthorProjection = authors.first;

        // Edit the record
        final updatedAuthor = newAuthorProjection.author.copyWith(
          name: 'Updated Test Author',
        );
        await updateAuthorUsecase.call(
          handle: newAuthorProjection.handle,
          author: updatedAuthor,
        );

        // Verify count remains the same
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.author.name, 'Updated Test Author');

        // Add another record
        await addAuthorUsecase.call(name: 'Second Author');

        // Verify count increases
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 2);
        final secondAuthorProjection = authors.firstWhere(
          (a) => a.author.name == 'Second Author',
        );

        // Get author by name
        var authorResult = await getAuthorByNameUsecase(
          name: 'Updated Test Author',
        );
        expect(authorResult.isRight(), true);
        var author = authorResult.fold((l) => null, (r) => r);
        expect(author, isNotNull);
        expect(author!.name, 'Updated Test Author');

        // Delete one record
        await deleteAuthorUsecase.call(name: 'Updated Test Author');

        // Verify count decreases
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.author.name, 'Second Author');

        // Add a book with the remaining author
        final tag = Tag(name: 'Test Tag');
        await addTagUsecase.call(tag: tag);

        final book = Book(
          businessIds: [
            BookIdPair(idType: BookIdType.local, idCode: "test_book"),
          ],
          title: 'Test Book',
          authors: [secondAuthorProjection.author],
          tags: [tag],
          publishedDate: DateTime(2023, 1, 1),
        );
        await addBookUsecase.call(book: book);

        // Verify book has the author
        var booksResult = await getBooksUsecase();
        expect(booksResult.isRight(), true);
        var books = booksResult.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.authors.length, 1);
        expect(books.first.authors.first.name, 'Second Author');

        // Delete the author
        await deleteAuthorUsecase.call(name: 'Second Author');

        // Verify author removed from book
        booksResult = await getBooksUsecase();
        expect(booksResult.isRight(), true);
        books = booksResult.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.authors.isEmpty, true);

        // Verify no authors left
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.isEmpty, true);

        // Close database
        logger.info('Closing database');
        await database.close();
        logger.info('Test completed');
      },
      timeout: Timeout(Duration(seconds: 60)),
    );
  });
}
