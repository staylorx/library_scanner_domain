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
      testDbPath: p.join('build', 'book_test_${const Uuid().v4()}'),
    );
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
          bookIdRegistryService: bookIdRegistryService,
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
          idRegistryService: authorIdRegistryService,
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
        var booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        var books = booksEither.getRight().getOrElse(() => <Book>[]);
        expect(books.isEmpty, true);

        // Add one record
        await addAuthorUsecase(name: 'Test Author');
        final authorsResult = await getAuthorsUsecase();
        expect(authorsResult.isRight(), true);
        final List<Author> authors = authorsResult.fold((l) => [], (r) => r);
        final newAuthor = authors.first;
        await addTagUsecase(name: 'Test Tag');
        final tagsResult = await tagRepository.getTags();
        expect(tagsResult.isRight(), true);
        final List<Tag> tags = tagsResult.fold((l) => [], (r) => r);
        final newTag = tags.firstWhere((t) => t.name == 'Test Tag');

        await addBookUsecase(
          title: 'New Test Book',
          authors: [newAuthor],
          tags: [newTag],
          publishedDate: DateTime(2023, 1, 1),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: "12345")],
        );

        // Verify count
        booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        books = booksEither.getRight().getOrElse(() => <Book>[]);
        expect(books.length, 1);
        expect(books.first.title, 'New Test Book');
        expect(books.first.authors.first.name, 'Test Author');
        expect(books.first.tags.first.name, 'Test Tag');

        // Edit the record
        final newBook = books.first;
        final updatedBook = newBook.copyWith(title: 'Updated Test Book');
        await updateBookUsecase(
          id: updatedBook.id,
          title: updatedBook.title,
          authors: updatedBook.authors,
          tags: updatedBook.tags,
          description: updatedBook.description,
          publishedDate: updatedBook.publishedDate,
          coverImage: updatedBook.coverImage,
          notes: updatedBook.notes,
          businessIds: updatedBook.businessIds,
        );

        // Verify count remains the same
        booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        books = booksEither.getRight().getOrElse(() => <Book>[]);
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
        await addAuthorUsecase(name: 'Second Author');
        final authorsResult2 = await getAuthorsUsecase();
        expect(authorsResult2.isRight(), true);
        final List<Author> authors2 = authorsResult2.fold((l) => [], (r) => r);

        final secondAuthor = authors2.firstWhere(
          (a) => a.name == 'Second Author',
        );
        await addTagUsecase(name: 'Second Tag');
        final tagsResult2 = await tagRepository.getTags();
        expect(tagsResult2.isRight(), true);
        final List<Tag> tags2 = tagsResult2.fold((l) => [], (r) => r);
        final secondTag = tags2.firstWhere((t) => t.name == 'Second Tag');

        final secondBook = Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: "67890")],
          title: 'Second Test Book',
          authors: [secondAuthor],
          tags: [secondTag],
          publishedDate: DateTime(2023, 2, 1),
        );
        await addBookUsecase(
          title: secondBook.title,
          authors: secondBook.authors,
          tags: secondBook.tags,
          description: secondBook.description,
          publishedDate: secondBook.publishedDate,
          coverImage: secondBook.coverImage,
          notes: secondBook.notes,
          businessIds: secondBook.businessIds,
        );

        // Verify count increases
        booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        books = booksEither.getRight().getOrElse(() => <Book>[]);
        expect(books.length, 2);

        // Delete one record
        await deleteBookUsecase(id: newBook.id);

        // Verify count decreases
        booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        books = booksEither.getRight().getOrElse(() => <Book>[]);
        expect(books.length, 1);
        expect(books.first.title, 'Second Test Book');
        final actualSecondBook = books.first;

        // Update the remaining book
        final finalUpdatedBook = actualSecondBook.copyWith(
          title: 'Final Updated Book',
        );
        await updateBookUsecase(
          id: finalUpdatedBook.id,
          title: finalUpdatedBook.title,
          authors: finalUpdatedBook.authors,
          tags: finalUpdatedBook.tags,
          description: finalUpdatedBook.description,
          publishedDate: finalUpdatedBook.publishedDate,
          coverImage: finalUpdatedBook.coverImage,
          notes: finalUpdatedBook.notes,
          businessIds: finalUpdatedBook.businessIds,
        );

        // Verify update
        bookResult = await getByIdPairUsecase(
          bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "67890"),
        );
        expect(bookResult.isRight(), true);
        book = bookResult.fold<Book?>((l) => null, (r) => r);
        expect(book, isNotNull);
        expect(book!.title, 'Final Updated Book');

        // Delete the last book
        await deleteBookUsecase(id: actualSecondBook.id);

        // Verify zero records
        booksEither = await getBooksUsecase();
        expect(booksEither.isRight(), true);
        books = booksEither.getRight().getOrElse(() => <Book>[]);
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
