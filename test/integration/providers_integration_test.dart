import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  late ProviderContainer container;
  late DatabaseService database;

  setUp(() async {
    // Set up real implementations for integration testing
    final dbPath = p.join(
      'build',
      'providers_integration_test_${const Uuid().v4()}',
    );
    database = SembastDatabase(testDbPath: dbPath);
    final unitOfWork = SembastUnitOfWork(dbService: database);

    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(Dio()),
        databaseServiceProvider.overrideWithValue(database),
        unitOfWorkProvider.overrideWithValue(unitOfWork),
        imageServiceProvider.overrideWith(
          (ref) =>
              throw UnimplementedError('ImageService not needed for this test'),
        ),
      ],
    );

    // Clear database before each test
    (await database.clearAll()).fold((l) => throw l, (r) => null);
  });

  tearDown(() async {
    await database.close();
    container.dispose();
  });

  group('Providers Integration Tests', () {
    test('End-to-end author management through providers', () async {
      // Get usecases from providers
      final addAuthorUsecase = await container.read(
        addAuthorUsecaseProvider.future,
      );
      final getAuthorsUsecase = await container.read(
        getAuthorsUsecaseProvider.future,
      );
      final updateAuthorUsecase = await container.read(
        updateAuthorUsecaseProvider.future,
      );
      final deleteAuthorUsecase = await container.read(
        deleteAuthorUsecaseProvider.future,
      );

      // Initially no authors
      var authorsResult = await getAuthorsUsecase();
      expect(authorsResult.isRight(), true);
      var authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.isEmpty, true);

      // Add an author
      final addResult = await addAuthorUsecase(name: 'Integration Test Author');
      expect(addResult.isRight(), true);

      // Verify author was added
      authorsResult = await getAuthorsUsecase();
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Integration Test Author');

      final author = authors.first;

      // Update the author
      final updateResult = await updateAuthorUsecase(
        id: author.id,
        name: 'Updated Integration Test Author',
      );
      expect(updateResult.isRight(), true);

      // Verify update
      authorsResult = await getAuthorsUsecase();
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Updated Integration Test Author');

      // Delete the author
      final deleteResult = await deleteAuthorUsecase(id: author.id);
      expect(deleteResult.isRight(), true);

      // Verify deletion
      authorsResult = await getAuthorsUsecase();
      expect(authorsResult.isRight(), true);
      authors = authorsResult.fold<List<Author>>((l) => [], (r) => r);
      expect(authors.isEmpty, true);
    });

    test('End-to-end book management through providers', () async {
      // Get usecases from providers
      final addAuthorUsecase = await container.read(
        addAuthorUsecaseProvider.future,
      );
      final addTagUsecase = await container.read(addTagUsecaseProvider.future);
      final addBookUsecase = await container.read(
        addBookUsecaseProvider.future,
      );
      final getBooksUsecase = await container.read(
        getBooksUsecaseProvider.future,
      );
      final updateBookUsecase = await container.read(
        updateBookUsecaseProvider.future,
      );
      final deleteBookUsecase = await container.read(
        deleteBookUsecaseProvider.future,
      );

      // Add prerequisite author and tag
      await addAuthorUsecase(name: 'Book Integration Author');
      final authorsResult = await container
          .read(getAuthorsUsecaseProvider.future)
          .then((usecase) => usecase());
      expect(authorsResult.isRight(), true);
      final Author author = authorsResult
          .fold<List<Author>>((l) => [], (r) => r)
          .first;

      await addTagUsecase(name: 'Book Integration Tag');
      final tagsResult = await container
          .read(tagRepositoryProvider.future)
          .then((repo) => repo.getTags());
      expect(tagsResult.isRight(), true);
      final Tag tag = tagsResult
          .fold<List<Tag>>((l) => [], (r) => r)
          .firstWhere((t) => t.name == 'Book Integration Tag');

      // Initially no books
      var booksResult = await getBooksUsecase();
      expect(booksResult.isRight(), true);
      var books = booksResult.fold<List<Book>>((l) => [], (r) => r);
      expect(books.isEmpty, true);

      // Add a book
      final addResult = await addBookUsecase(
        title: 'Integration Test Book',
        authors: [author],
        tags: [tag],
        publishedDate: DateTime(2023, 1, 1),
        businessIds: [
          BookIdPair(idType: BookIdType.local, idCode: 'integration123'),
        ],
      );
      expect(addResult.isRight(), true);

      // Verify book was added
      booksResult = await getBooksUsecase();
      expect(booksResult.isRight(), true);
      books = booksResult.fold<List<Book>>((l) => [], (r) => r);
      expect(books.length, 1);
      expect(books.first.title, 'Integration Test Book');
      expect(books.first.authors.first.name, 'Book Integration Author');
      expect(books.first.tags.first.name, 'Book Integration Tag');

      final Book book = books.first;

      // Update the book
      final updateResult = await updateBookUsecase(
        id: book.id,
        title: 'Updated Integration Test Book',
        authors: book.authors,
        tags: book.tags,
        publishedDate: book.publishedDate,
        businessIds: book.businessIds,
      );
      expect(updateResult.isRight(), true);

      // Verify update
      booksResult = await getBooksUsecase();
      expect(booksResult.isRight(), true);
      books = booksResult.fold((l) => [], (r) => r);
      expect(books.length, 1);
      expect(books.first.title, 'Updated Integration Test Book');

      // Delete the book
      final deleteResult = await deleteBookUsecase(id: book.id);
      expect(deleteResult.isRight(), true);

      // Verify deletion
      booksResult = await getBooksUsecase();
      expect(booksResult.isRight(), true);
      books = booksResult.fold((l) => [], (r) => r);
      expect(books.isEmpty, true);
    });

    test('Library stats through providers', () async {
      final getLibraryStatsUsecase = await container.read(
        getLibraryStatsUsecaseProvider.future,
      );

      // Initially empty
      final statsResult = await getLibraryStatsUsecase();
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
  }, timeout: Timeout(Duration(seconds: 60)));
}
