import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_pair_set/id_pair_set.dart';

void main() {
  group('Author Integration Tests', () {
    late Directory tempDir;
    late SembastDatabase database;
    late AuthorRepositoryImpl authorRepository;
    late GetAuthorsUsecase getAuthorsUsecase;
    late GetAuthorByNameUsecase getAuthorByNameUsecase;
    late AddAuthorUsecase addAuthorUsecase;
    late UpdateAuthorUsecase updateAuthorUsecase;
    late DeleteAuthorUsecase deleteAuthorUsecase;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_db');
      final dbPath = join(tempDir.path, 'book_inventory.db');
      database = SembastDatabase(testDbPath: dbPath);
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      authorRepository = AuthorRepositoryImpl(databaseService: database);

      getAuthorsUsecase = GetAuthorsUsecase(authorRepository);
      getAuthorByNameUsecase = GetAuthorByNameUsecase(authorRepository);
      addAuthorUsecase = AddAuthorUsecase(authorRepository);
      updateAuthorUsecase = UpdateAuthorUsecase(authorRepository);
      deleteAuthorUsecase = DeleteAuthorUsecase(authorRepository);
    });

    tearDown(() async {
      // Close database
      await database.close();
      tempDir.deleteSync(recursive: true);
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
  });
}
