import 'dart:io';

import 'package:test/test.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  group('Book Integration Tests', () {
    late Directory tempDir;
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
      tempDir = await Directory.systemTemp.createTemp('test_db');
      final dbPath = join(tempDir.path, 'book_inventory.db');
      database = SembastDatabase(testDbPath: dbPath);
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      bookRepository = BookRepositoryImpl(database: database, isBookDuplicateUsecase: IsBookDuplicateUsecase());

      getBooksUsecase = GetBooksUsecase(bookRepository);
      getBookByIdPairUsecase = GetBookByIdPairUsecase(bookRepository);
      addBookUsecase = AddBookUsecase(bookRepository);
      updateBookUsecase = UpdateBookUsecase(bookRepository);
      deleteBookUsecase = DeleteBookUsecase(bookRepository);
      addAuthorUsecase = AddAuthorUsecase(AuthorRepositoryImpl(databaseService: database));
      addTagUsecase = AddTagUsecase(TagRepositoryImpl(databaseService: database));
    });

    tearDown(() async {
      // Close database
      await database.close();
      tempDir.deleteSync(recursive: true);
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