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
      testDbPath: p.join('build', 'author_usecases_test'),
    );
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('Author UseCases Integration Tests', () {
    test(
      'Comprehensive Author UseCases Integration Test',
      () async {
        final logger = SimpleLoggerImpl(name: 'AuthorTest');
        logger.logLevel = null;

        logger.info('Starting comprehensive test');

        logger.info('Database instance created');
        (await database.clearAll()).fold((l) => throw l, (r) => null);
        logger.info('Database cleared');

        final authorIdRegistryService = AuthorIdRegistryServiceImpl();
        final bookIdRegistryService = BookIdRegistryServiceImpl();
        final unitOfWork = SembastUnitOfWork(dbService: database);
        final authorRepository = AuthorRepositoryImpl(
          authorDatasource: authorDatasource,
          unitOfWork: unitOfWork,
          idRegistryService: authorIdRegistryService,
        );
        final bookRepository = BookRepositoryImpl(
          authorDatasource: authorDatasource,
          bookDatasource: bookDatasource,
          idRegistryService: bookIdRegistryService,
          tagDatasource: tagDatasource,
          unitOfWork: unitOfWork,
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
          bookIdRegistryService: bookIdRegistryService,
        );
        final tagRepository = TagRepositoryImpl(
          tagDatasource: tagDatasource,

          unitOfWork: unitOfWork,
        );
        final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);

        // Check for zero records
        var result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        List<Author> authors = result.fold((l) => [], (r) => r);
        expect(authors.isEmpty, true);

        // Add one record
        await addAuthorUsecase(name: 'Test Author');

        // Verify count
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Test Author');
        final newAuthor = authors.first;

        // Edit the record
        final updatedAuthor = newAuthor.copyWith(name: 'Updated Test Author');
        await updateAuthorUsecase(
          id: newAuthor.id,
          name: updatedAuthor.name,
          biography: updatedAuthor.biography,
        );

        // Verify count remains the same
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Updated Test Author');

        // Add another record
        await addAuthorUsecase(name: 'Second Author');

        // Verify count increases
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 2);
        final secondAuthor = authors.firstWhere(
          (a) => a.name == 'Second Author',
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
        await deleteAuthorUsecase(id: newAuthor.id);

        // Verify count decreases
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Second Author');

        // Add a book with the remaining author
        final tag = Tag(id: const Uuid().v4(), name: 'Test Tag');
        await addTagUsecase(name: tag.name);

        final book = Book(
          id: const Uuid().v4(),
          businessIds: [
            BookIdPair(idType: BookIdType.local, idCode: "test_book"),
          ],
          title: 'Test Book',
          authors: [secondAuthor],
          tags: [tag],
          publishedDate: DateTime(2023, 1, 1),
        );
        await addBookUsecase(
          title: book.title,
          authors: book.authors,
          tags: book.tags,
          description: book.description,
          publishedDate: book.publishedDate,
          coverImage: book.coverImage,
          notes: book.notes,
          businessIds: book.businessIds,
        );

        // Verify book has the author
        var booksResult = await getBooksUsecase();
        expect(booksResult.isRight(), true);
        var books = booksResult.fold((l) => [], (r) => r);
        expect(books.length, 1);
        expect(books.first.authors.length, 1);
        expect(books.first.authors.first.name, 'Second Author');

        // Delete the author
        await deleteAuthorUsecase(id: secondAuthor.id);

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
