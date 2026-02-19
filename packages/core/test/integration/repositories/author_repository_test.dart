import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseService database;
  late AuthorDatasource authorDatasource;

  setUpAll(() async {
    database = SembastDatabase(
      testDbPath: p.join(
        'build',
        'author_repository_test_${const Uuid().v4()}',
      ),
    );
    authorDatasource = AuthorDatasource(dbService: database);
  });

  group('AuthorRepository Integration Tests', () {
    test('AuthorRepository CRUD operations', () async {
      final logger = SimpleLoggerImpl(name: 'AuthorRepositoryTest');
      logger.info('Starting AuthorRepository test');

      logger.info('Database instance created');
      await database.clearAll().run();
      logger.info('Database cleared');

      final authorIdRegistryService = AuthorIdRegistryServiceImpl();
      final unitOfWork = SembastUnitOfWork(dbService: database);
      final authorRepository = AuthorRepositoryImpl(
        authorDatasource: authorDatasource,
        unitOfWork: unitOfWork,
        idRegistryService: authorIdRegistryService,
      );

      // Check for zero authors
      var authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      var authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.isEmpty, true);

      // Add one author
      final newAuthor = Author(
        id: const Uuid().v4(),
        businessIds: [
          AuthorIdPair(idType: AuthorIdType.local, idCode: "author1"),
        ],
        name: 'Test Author',
        biography: 'Test bio',
      );
      await authorRepository.create(item: newAuthor).run();

      // Verify count
      authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Test Author');

      // Update the author
      final updatedAuthor = authors.first.copyWith(name: 'Updated Test Author');
      await authorRepository.update(item: updatedAuthor).run();

      // Verify update
      authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Updated Test Author');

      // Get author by name
      var authorResult = await authorRepository
          .getAuthorByName(name: 'Updated Test Author')
          .run();
      expect(authorResult.isRight(), true);
      var author = authorResult.fold((l) => null, (r) => r);
      expect(author, isNotNull);
      expect(author!.name, 'Updated Test Author');

      // Add another author
      final secondAuthor = Author(
        id: const Uuid().v4(),
        businessIds: [
          AuthorIdPair(idType: AuthorIdType.local, idCode: "author2"),
        ],
        name: 'Second Author',
      );
      await authorRepository.create(item: secondAuthor).run();

      // Verify count increases
      authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.length, 2);

      // Delete one author
      await authorRepository.deleteById(item: updatedAuthor).run();

      // Verify count decreases
      authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.length, 1);
      expect(authors.first.name, 'Second Author');

      // Delete the last author
      await authorRepository.deleteById(item: secondAuthor).run();

      // Verify zero authors
      authorsEither = await authorRepository.getAll().run();
      expect(authorsEither.isRight(), true);
      authors = authorsEither.fold((l) => <Author>[], (r) => r);
      expect(authors.isEmpty, true);

      // Close database
      logger.info('Closing database');
      database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
