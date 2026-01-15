import 'dart:io';

import 'package:test/test.dart' show test, expect, group, Timeout;
import 'package:matcher/matcher.dart';
import 'package:logging/logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  group('Author Integration Tests', () {
    test(
      'Comprehensive Author Integration Test',
      () async {
        final logger = Logger('AuthorTest');
        logger.info('Starting comprehensive test');

        final database = SembastDatabase(testDbPath: null);
        logger.info('Database instance created');
        (await database.clearAll()).fold((l) => throw l, (r) => null);
        logger.info('Database cleared');

        final authorIdRegistryService = AuthorIdRegistryServiceImpl();
        final bookIdRegistryService = BookIdRegistryServiceImpl();
        final authorRepository = AuthorRepositoryImpl(
          databaseService: database,
          idRegistryService: authorIdRegistryService,
        );
        final bookRepository = BookRepositoryImpl(
          database: database,
          idRegistryService: bookIdRegistryService,
        );

        final getAuthorsUsecase = GetAuthorsUsecase(
          authorRepository: authorRepository,
        );
        final getAuthorByNameUsecase = GetAuthorByNameUsecase(
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
        final addTagUsecase = AddTagUsecase(
          tagRepository: TagRepositoryImpl(databaseService: database),
        );

        // Check for zero records
        var result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        List<Author> authors = result.fold((l) => [], (r) => r);
        expect(authors.isEmpty, true);

        // Add one record
        await addAuthorUsecase.call(name: 'Test Author');

        // Verify count
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Test Author');
        final newAuthor = authors.first;

        // Edit the record
        final updatedAuthor = newAuthor.copyWith(name: 'Updated Test Author');
        await updateAuthorUsecase.call(
          handle: AuthorHandle.fromName(newAuthor.name),
          author: updatedAuthor,
        );

        // Verify count remains the same
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Updated Test Author');

        // Add another record
        await addAuthorUsecase.call(name: 'Second Author');

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
        await deleteAuthorUsecase.call(name: 'Updated Test Author');

        // Verify count decreases
        result = await getAuthorsUsecase();
        expect(result.isRight(), true);
        authors = result.fold((l) => [], (r) => r);
        expect(authors.length, 1);
        expect(authors.first.name, 'Second Author');

        // Add a book with the remaining author
        final tag = Tag(id: TagHandle.fromName('Test Tag'), name: 'Test Tag');
        await addTagUsecase.call(tag: tag);

        final book = Book(
          businessIds: [
            BookIdPair(idType: BookIdType.local, idCode: "test_book"),
          ],
          title: 'Test Book',
          authors: [secondAuthor],
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
