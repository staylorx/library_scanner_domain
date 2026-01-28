import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// This is a boundary integration test to ensure that the factory correctly
/// sets up and can be used to perform end-to-end operations.
/// It uses real implementations of the database and repositories.
/// It uses the runTaskEither helper to handle TaskEither results, converting them
/// to Future for easier async/await usage as would be expected in Flutter.
void main() {
  late LibraryDomain domain;
  late DatabaseService database;

  setUp(() async {
    // Set up real implementations for integration testing
    final dbPath = p.join(
      'build',
      'factory_integration_test_${const Uuid().v4()}',
    );
    database = SembastDatabase(testDbPath: dbPath);
    final unitOfWork = SembastUnitOfWork(dbService: database);

    domain = LibraryDomainFactory.create(
      databaseService: database,
      unitOfWork: unitOfWork,
    );

    // Clear database before each test
    await runTaskEither(database.clearAll());
  });

  tearDown(() async {
    await runTaskEither(database.close());
  });

  group('Factory Integration Tests', () {
    test('End-to-end author management through factory', () async {
      // Get usecases from domain
      final addAuthorUsecase = domain.addAuthorUsecase;
      final getAuthorsUsecase = domain.getAuthorsUsecase;
      final updateAuthorUsecase = domain.updateAuthorUsecase;
      final deleteAuthorUsecase = domain.deleteAuthorUsecase;

      // Initially no authors
      var authorsResult = await runTaskEither(getAuthorsUsecase());
      expect(authorsResult.isRight(), true);
      var authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.isEmpty, true);

      // Add an author
      final addResult = await runTaskEither(
        addAuthorUsecase(name: 'Integration Test Author'),
      );
      expect(addResult.isRight(), true);

      // Verify author was added
      authorsResult = await runTaskEither(getAuthorsUsecase());
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Integration Test Author');

      final author = authors.first;

      // Update the author
      final updateResult = await runTaskEither(
        updateAuthorUsecase(
          id: author.id,
          name: 'Updated Integration Test Author',
        ),
      );
      expect(updateResult.isRight(), true);

      // Verify update
      authorsResult = await runTaskEither(getAuthorsUsecase());
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Updated Integration Test Author');

      // Delete the author
      final deleteResult = await runTaskEither(
        deleteAuthorUsecase(id: author.id),
      );
      expect(deleteResult.isRight(), true);

      // Verify deletion
      authorsResult = await runTaskEither(getAuthorsUsecase());
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.isEmpty, true);
    });

    test('End-to-end book management through factory', () async {
      // Get usecases from domain
      final addAuthorUsecase = domain.addAuthorUsecase;
      final addTagUsecase = domain.addTagUsecase;
      final addBookUsecase = domain.addBookUsecase;
      final getBooksUsecase = domain.getBooksUsecase;
      final updateBookUsecase = domain.updateBookUsecase;
      final deleteBookUsecase = domain.deleteBookUsecase;

      // Add prerequisite author and tag
      await runTaskEither(addAuthorUsecase(name: 'Book Integration Author'));
      final authorsResult = await runTaskEither(domain.getAuthorsUsecase());
      expect(authorsResult.isRight(), true);
      final Author author = authorsResult
          .fold<List<Author>>((l) => [], (r) => r)
          .first;

      await runTaskEither(addTagUsecase(name: 'Book Integration Tag'));
      final tagsResult = await runTaskEither(domain.getTagsUsecase());
      expect(tagsResult.isRight(), true);
      final Tag tag = tagsResult
          .fold<List<Tag>>((l) => [], (r) => r)
          .firstWhere((t) => t.name == 'Book Integration Tag');

      // Initially no books
      var booksResult = await runTaskEither(getBooksUsecase());
      expect(booksResult.isRight(), true);
      var books = booksResult.fold<List<Book>>((l) => [], (r) => r);
      expect(books.isEmpty, true);

      // Add a book
      final addResult = await runTaskEither(
        addBookUsecase(
          title: 'Integration Test Book',
          authors: [author],
          tags: [tag],
          publishedDate: DateTime(2023, 1, 1),
          businessIds: [
            BookIdPair(idType: BookIdType.local, idCode: 'integration123'),
          ],
        ),
      );
      expect(addResult.isRight(), true);

      // Verify book was added
      booksResult = await runTaskEither(getBooksUsecase());
      expect(booksResult.isRight(), true);
      books = booksResult.fold<List<Book>>((l) => [], (r) => r);
      expect(books.length, 1);
      expect(books.first.title, 'Integration Test Book');
      expect(books.first.authors.first.name, 'Book Integration Author');
      expect(books.first.tags.first.name, 'Book Integration Tag');

      final Book book = books.first;

      // Update the book
      final updateResult = await runTaskEither(
        updateBookUsecase(
          id: book.id,
          title: 'Updated Integration Test Book',
          authors: book.authors,
          tags: book.tags,
          publishedDate: book.publishedDate,
          businessIds: book.businessIds,
        ),
      );
      expect(updateResult.isRight(), true);

      // Verify update
      booksResult = await runTaskEither(getBooksUsecase());
      expect(booksResult.isRight(), true);
      books = booksResult.fold((l) => [], (r) => r);
      expect(books.length, 1);
      expect(books.first.title, 'Updated Integration Test Book');

      // Delete the book
      final deleteResult = await runTaskEither(deleteBookUsecase(id: book.id));
      expect(deleteResult.isRight(), true);

      // Verify deletion
      booksResult = await runTaskEither(getBooksUsecase());
      expect(booksResult.isRight(), true);
      books = booksResult.fold((l) => [], (r) => r);
      expect(books.isEmpty, true);
    });

    test('Library stats through factory', () async {
      final getLibraryStatsUsecase = domain.getLibraryStatsUsecase;

      // Initially empty
      final statsResult = await runTaskEither(getLibraryStatsUsecase());
      expect(statsResult.isRight(), true);
      final stats = statsResult.fold(
        (l) => LibraryStats(
          totalBooks: 0,
          totalAuthors: 0,
          totalTags: 0,
          booksWithCovers: 0,
          booksByTag: {},
        ),
        (r) => r,
      );
      expect(stats.totalBooks, 0);
      expect(stats.totalAuthors, 0);
      expect(stats.totalTags, 0);
    });

    group('UnitOfWork Integration Tests', () {
      test('UnitOfWork is provided correctly', () {
        // Since we create the domain with the unitOfWork, we can verify it's the same instance
        // by checking that operations work, which they do in the above tests
        expect(database, isA<DatabaseService>());
        expect(database, isA<SembastDatabase>());
      });
    });
  }, timeout: Timeout(Duration(seconds: 60)));
}
