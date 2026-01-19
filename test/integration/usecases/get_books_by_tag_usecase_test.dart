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
      testDbPath: p.join(
        'build',
        'get_books_by_tag_usecase_test_${const Uuid().v4()}',
      ),
    );
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('GetBooksByTagUseCase Integration Tests', () {
    test('Get Books By Tag Integration Test', () async {
      final logger = SimpleLoggerImpl(name: 'GetBooksByTagTest');
      logger.info('Starting getBooksByTag test');

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

      final getBooksByTagUsecase = GetBooksByTagUseCase(
        bookRepository: bookRepository,
      );
      final addBookUsecase = AddBookUsecase(
        bookRepository: bookRepository,
        isBookDuplicateUsecase: IsBookDuplicateUsecase(),
        bookIdRegistryService: bookIdRegistryService,
      );
      final authorRepository = AuthorRepositoryImpl(
        authorDatasource: authorDatasource,
        unitOfWork: unitOfWork,
        idRegistryService: authorIdRegistryService,
      );
      final addAuthorUsecase = AddAuthorUsecase(
        authorRepository: authorRepository,
        idRegistryService: authorIdRegistryService,
      );
      final tagRepository = TagRepositoryImpl(
        tagDatasource: tagDatasource,
        unitOfWork: unitOfWork,
      );
      final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);

      // Add authors
      await addAuthorUsecase(name: 'Author One');
      await addAuthorUsecase(name: 'Author Two');
      final authorsResult = await authorRepository.getAuthors();
      expect(authorsResult.isRight(), true);
      final List<Author> authors = authorsResult.fold(
        (l) => <Author>[],
        (r) => r,
      );
      final authorOne = authors.firstWhere((a) => a.name == 'Author One');
      final authorTwo = authors.firstWhere((a) => a.name == 'Author Two');

      // Add tags
      await addTagUsecase(name: 'Fiction');
      await addTagUsecase(name: 'Sci-Fi');
      await addTagUsecase(name: 'Mystery');
      final tagsResult = await tagRepository.getTags();
      expect(tagsResult.isRight(), true);
      final List<Tag> tags = tagsResult.fold((l) => <Tag>[], (r) => r);
      final fictionTag = tags.firstWhere((t) => t.name == 'Fiction');
      final sciFiTag = tags.firstWhere((t) => t.name == 'Sci-Fi');
      final mysteryTag = tags.firstWhere((t) => t.name == 'Mystery');

      // Add books with different tag combinations
      final addResult1 = await addBookUsecase(
        title: 'Book One',
        authors: [authorOne],
        tags: [fictionTag],
        publishedDate: DateTime(2023, 1, 1),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "book1")],
      );
      expect(addResult1.isRight(), true);
      final booksAfterAdd1 = addResult1.getRight().getOrElse(() => []);
      expect(booksAfterAdd1.length, 1);
      expect(booksAfterAdd1.first.title, 'Book One');
      expect(booksAfterAdd1.first.tags.length, 1);
      expect(booksAfterAdd1.first.tags.first.name, 'Fiction');

      await addBookUsecase(
        title: 'Book Two',
        authors: [authorOne],
        tags: [fictionTag, sciFiTag],
        publishedDate: DateTime(2023, 2, 1),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "book2")],
      );

      await addBookUsecase(
        title: 'Book Three',
        authors: [authorTwo],
        tags: [sciFiTag],
        publishedDate: DateTime(2023, 3, 1),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "book3")],
      );

      await addBookUsecase(
        title: 'Book Four',
        authors: [authorTwo],
        tags: [mysteryTag],
        publishedDate: DateTime(2023, 4, 1),
        businessIds: [BookIdPair(idType: BookIdType.local, idCode: "book4")],
      );

      // Check total books
      final allBooksResult = await bookRepository.getBooks();
      expect(allBooksResult.isRight(), true);
      final allBooks = allBooksResult.getRight().getOrElse(() => []);
      expect(allBooks.length, 4);

      // Test getBooksByTag for Fiction tag
      var result = await getBooksByTagUsecase(tag: fictionTag);
      expect(result.isRight(), true);
      var books = result.fold((l) => <Book>[], (r) => r);
      expect(books.length, 2);
      expect(books.any((b) => b.title == 'Book One'), true);
      expect(books.any((b) => b.title == 'Book Two'), true);
      expect(books.every((b) => b.tags.any((t) => t.name == 'Fiction')), true);

      // Test getBooksByTag for Sci-Fi tag
      result = await getBooksByTagUsecase(tag: sciFiTag);
      expect(result.isRight(), true);
      books = result.fold((l) => <Book>[], (r) => r);
      expect(books.length, 2);
      expect(books.any((b) => b.title == 'Book Two'), true);
      expect(books.any((b) => b.title == 'Book Three'), true);
      expect(books.every((b) => b.tags.any((t) => t.name == 'Sci-Fi')), true);

      // Test getBooksByTag for Mystery tag
      result = await getBooksByTagUsecase(tag: mysteryTag);
      expect(result.isRight(), true);
      books = result.fold((l) => <Book>[], (r) => r);
      expect(books.length, 1);
      expect(books.first.title, 'Book Four');
      expect(books.first.tags.any((t) => t.name == 'Mystery'), true);

      // Test getBooksByTag for a tag with no books (create a new tag)
      await addTagUsecase(name: 'Empty Tag');
      final emptyTagsResult = await tagRepository.getTags();
      expect(emptyTagsResult.isRight(), true);
      final List<Tag> emptyTags = emptyTagsResult.fold(
        (l) => <Tag>[],
        (r) => r,
      );
      final emptyTag = emptyTags.firstWhere((t) => t.name == 'Empty Tag');

      result = await getBooksByTagUsecase(tag: emptyTag);
      expect(result.isRight(), true);
      books = result.fold((l) => <Book>[], (r) => r);
      expect(books.isEmpty, true);

      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
