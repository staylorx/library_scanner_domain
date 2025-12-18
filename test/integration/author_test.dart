// ignore_for_file: avoid_print

import 'package:test/test.dart';
import 'package:logging/logging.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_pair_set/id_pair_set.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  group('Author Integration Tests', () {
    late SembastDatabase database;
    late AuthorRepositoryImpl authorRepository;
    late BookRepositoryImpl bookRepository;
    late GetAuthorsUsecase getAuthorsUsecase;
    late GetAuthorByNameUsecase getAuthorByNameUsecase;
    late AddAuthorUsecase addAuthorUsecase;
    late UpdateAuthorUsecase updateAuthorUsecase;
    late DeleteAuthorUsecase deleteAuthorUsecase;
    late GetBooksUsecase getBooksUsecase;
    late AddBookUsecase addBookUsecase;
    late AddTagUsecase addTagUsecase;

    setUp(() async {
      final logger = Logger('AuthorTest');
      logger.info('Starting setUp');
      database = SembastDatabase(testDbPath: null);
      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');
      authorRepository = AuthorRepositoryImpl(databaseService: database);
      bookRepository = BookRepositoryImpl(
        database: database,
        isBookDuplicateUsecase: IsBookDuplicateUsecase(),
      );

      getAuthorsUsecase = GetAuthorsUsecase(authorRepository: authorRepository);
      getAuthorByNameUsecase = GetAuthorByNameUsecase(
        authorRepository: authorRepository,
      );
      addAuthorUsecase = AddAuthorUsecase(authorRepository: authorRepository);
      updateAuthorUsecase = UpdateAuthorUsecase(
        authorRepository: authorRepository,
      );
      deleteAuthorUsecase = DeleteAuthorUsecase(
        authorRepository: authorRepository,
      );
      getBooksUsecase = GetBooksUsecase(bookRepository: bookRepository);
      addBookUsecase = AddBookUsecase(bookRepository: bookRepository);
      addTagUsecase = AddTagUsecase(
        tagRepository: TagRepositoryImpl(databaseService: database),
      );
    });

    tearDown(() async {
      final logger = Logger('AuthorTest');
      logger.info('Starting tearDown');
      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('tearDown completed');
    });

    test('GetAuthorsUsecase should return authors', () async {
      final result = await getAuthorsUsecase();
      expect(result.isRight(), true);
      final authors = result.getRight().fold(() => [], (value) => value);
      expect(authors.isEmpty, true);
    });

    test(
      'GetAuthorByNameUsecase should get author by ID and verify properties',
      () async {
        final newAuthor = Author(
          idPairs: IdPairSet([
            AuthorIdPair(idType: AuthorIdType.local, idCode: 'Test Author'),
          ]),
          name: 'Test Author',
        );
        await addAuthorUsecase.call(author: newAuthor);

        final result = await getAuthorByNameUsecase(name: newAuthor.name);
        expect(result.isRight(), true);
        final author = result.getRight().fold<Author?>(
          () => null,
          (value) => value,
        );
        expect(author, isNotNull);
        expect(author?.name, newAuthor.name);
      },
    );

    test('AddAuthorUsecase should add new author', () async {
      final newAuthor = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'New Author'),
        ]),
        name: 'New Author',
      );

      final result = await addAuthorUsecase.call(author: newAuthor);
      expect(result.isRight(), true);

      // Verify added
      final authorsResult = await getAuthorsUsecase();
      expect(authorsResult.isRight(), true);
      final authors = authorsResult.getRight().fold<List<Author>>(
        () => [],
        (value) => value,
      );
      expect(authors.length, 1);
      final addedAuthor = authors.firstWhere((a) => a.name == 'New Author');
      expect(addedAuthor, isNotNull);
    });

    test('UpdateAuthorUsecase should update existing author', () async {
      final existingAuthor = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Existing Author'),
        ]),
        name: 'Existing Author',
      );
      await addAuthorUsecase.call(author: existingAuthor);

      final updatedAuthor = existingAuthor.copyWith(
        name: 'Existing Author Updated',
      );

      final result = await updateAuthorUsecase.call(author: updatedAuthor);
      expect(result.isRight(), true);

      // Verify updated
      final updatedResult = await getAuthorByNameUsecase(
        name: updatedAuthor.name,
      );
      expect(updatedResult.isRight(), true);
      final author = updatedResult.getRight().fold<Author?>(
        () => null,
        (value) => value,
      );
      expect(author, isNotNull);
      expect(author!.name, 'Existing Author Updated');
    });

    test('DeleteAuthorUsecase should delete author', () async {
      final authorToDelete = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Author to Delete'),
        ]),
        name: 'Author to Delete',
      );
      await addAuthorUsecase.call(author: authorToDelete);

      final result = await deleteAuthorUsecase.call(name: authorToDelete.name);
      expect(result.isRight(), true);

      // Verify deleted
      final afterDeleteResult = await getAuthorsUsecase();
      expect(afterDeleteResult.isRight(), true);
      final afterAuthors = afterDeleteResult.getRight().fold<List<Author>>(
        () => [],
        (value) => value,
      );
      expect(afterAuthors.isEmpty, true);
    });

    test('DeleteAuthorUsecase should remove author from books', () async {
      final authorToDelete = Author(
        idPairs: IdPairSet([
          AuthorIdPair(idType: AuthorIdType.local, idCode: 'Author to Delete from Books'),
        ]),
        name: 'Author to Delete from Books',
      );
      await addAuthorUsecase.call(author: authorToDelete);

      final tag = Tag(name: 'Test Tag');
      await addTagUsecase.call(tag: tag);

      final book = Book(
        title: 'Test Book',
        authors: [authorToDelete],
        tags: [tag],
        publishedDate: DateTime(2023, 1, 1),
        idPairs: IdPairSet([
          BookIdPair(idType: BookIdType.local, idCode: "delete_test"),
        ]),
      );
      await addBookUsecase.call(book: book);

      // Verify book has the author
      final booksBefore = await getBooksUsecase();
      expect(booksBefore.isRight(), true);
      final booksList = booksBefore.getRight().fold(() => [], (value) => value);
      expect(booksList.length, 1);
      expect(booksList.first.authors.length, 1);
      expect(booksList.first.authors.first.name, authorToDelete.name);

      // Delete the author
      final deleteResult = await deleteAuthorUsecase.call(name: authorToDelete.name);
      expect(deleteResult.isRight(), true);

      // Verify author removed from book
      final booksAfter = await getBooksUsecase();
      expect(booksAfter.isRight(), true);
      final booksAfterList = booksAfter.getRight().fold(() => [], (value) => value);
      expect(booksAfterList.length, 1);
      expect(booksAfterList.first.authors.isEmpty, true);
    });
  });
}
