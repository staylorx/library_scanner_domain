// ignore_for_file: avoid_print

import 'package:test/test.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'package:logging/logging.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });



  group('Book Integration Tests', () {
    late SembastDatabase database;
    late BookRepositoryImpl bookRepository;
    late GetBooksUsecase getBooksUsecase;
    late GetBookByIdPairUsecase getBookByIdPairUsecase;
    late AddBookUsecase addBookUsecase;
    late UpdateBookUsecase updateBookUsecase;
    late DeleteBookUsecase deleteBookUsecase;
    late AddAuthorUsecase addAuthorUsecase;
    late AddTagUsecase addTagUsecase;

    setUp(() async {
      final logger = Logger('BookTest');
      logger.info('Starting setUp');
      database = SembastDatabase(testDbPath: null);
      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');
      bookRepository = BookRepositoryImpl(
        database: database,
        isBookDuplicateUsecase: IsBookDuplicateUsecase(),
      );

      getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);
      getBookByIdPairUsecase = GetBookByIdPairUsecase(
        bookRepository: bookRepository,
      );
      addBookUsecase = AddBookUsecase(bookRepository: bookRepository);
      updateBookUsecase = UpdateBookUsecase(bookRepository: bookRepository);
      deleteBookUsecase = DeleteBookUsecase(bookRepository: bookRepository);
      addAuthorUsecase = AddAuthorUsecase(
        authorRepository: AuthorRepositoryImpl(databaseService: database),
      );
      addTagUsecase = AddTagUsecase(
        tagRepository: TagRepositoryImpl(databaseService: database),
      );
    });

    tearDown(() async {
      final logger = Logger('BookTest');
      logger.info('Starting tearDown');
      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('tearDown completed');
    });

    test('GetBooksUsecase should return empty list initially', () async {
      final result = await getBooksUsecase();
      expect(result.isRight(), true);
      final books = result.getRight().fold(() => [], (value) => value);
      expect(books.isEmpty, true);
    });

    test('AddBookUsecase should add new book', () async {
      final newAuthor = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Test Author'),
        ]),
        name: 'Test Author',
      );
      await addAuthorUsecase.call(author: newAuthor);
      final newTag = Tag(name: 'Test Tag');
      await addTagUsecase.call(tag: newTag);

      final newBook = Book(
        title: 'New Test Book',
        authors: [newAuthor],
        tags: [newTag],
        publishedDate: DateTime(2023, 1, 1),
        idPairs: IdPairSet([
          BookIdPair(idType: BookIdType.local, idCode: "12345"),
        ]),
      );

      final result = await addBookUsecase.call(book: newBook);
      expect(result.isRight(), true);

      // Verify added
      final booksResult = await getBooksUsecase();
      expect(booksResult.isRight(), true);
      final books = booksResult.getRight().fold<List<Book>>(
        () => [],
        (value) => value,
      );
      expect(books.length, 1);
      final addedBook = books.firstWhere(
        (b) => b.idPairs.idPairs.first.idCode == '12345',
      );
      expect(addedBook, isNotNull);
      expect(addedBook.title, 'New Test Book');
      expect(addedBook.authors.first.name, 'Test Author');
      expect(addedBook.tags.first.name, 'test tag');
    });

    test('UpdateBookUsecase should update existing book', () async {
      final existingAuthor = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Existing Author'),
        ]),
        name: 'Existing Author',
      );
      await addAuthorUsecase.call(author: existingAuthor);
      final existingTag = Tag(name: 'Existing Tag');
      await addTagUsecase.call(tag: existingTag);

      final existingBook = Book(
        title: 'Existing Book',
        authors: [existingAuthor],
        tags: [existingTag],
        publishedDate: DateTime(2023, 1, 1),
        idPairs: IdPairSet([
          BookIdPair(idType: BookIdType.local, idCode: "54321"),
        ]),
      );
      await addBookUsecase.call(book: existingBook);

      final updatedBook = existingBook.copyWith(title: 'Updated Book Title');

      final result = await updateBookUsecase.call(book: updatedBook);
      expect(result.isRight(), true);

      // Verify updated
      final book = await getBookByIdPairUsecase(
        bookIdPair: BookIdPair(idType: BookIdType.local, idCode: "54321"),
      );
      expect(book.isRight(), true);
      final updatedData = book.getRight().fold<Book?>(
        () => null,
        (value) => value,
      );
      expect(updatedData, isNotNull);
      expect(updatedData!.title, 'Updated Book Title');
    });

    test('DeleteBookUsecase should delete book', () async {
      final authorForBook = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Author For Book'),
        ]),
        name: 'Author For Book',
      );
      await addAuthorUsecase.call(author: authorForBook);
      final tagForBook = Tag(name: 'Tag For Book');
      await addTagUsecase.call(tag: tagForBook);

      final bookToDelete = Book(
        title: 'Book to Delete',
        authors: [authorForBook],
        tags: [tagForBook],
        publishedDate: DateTime(2023, 1, 1),
        idPairs: IdPairSet([
          BookIdPair(idType: BookIdType.local, idCode: "98765"),
        ]),
      );
      await addBookUsecase.call(book: bookToDelete);

      final result = await deleteBookUsecase.call(
        bookIdPair: bookToDelete.idPairs.idPairs.first,
      );
      expect(result.isRight(), true);

      // Verify deleted
      final afterDeleteResult = await getBooksUsecase();
      expect(afterDeleteResult.isRight(), true);
      final afterBooks = afterDeleteResult.getRight().fold<List<Book>>(
        () => [],
        (value) => value,
      );
      expect(afterBooks.isEmpty, true);
    });
  });
}
