import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseService database;
  late TagDatasource tagDatasource;

  setUpAll(() async {
    database = SembastDatabase(
      testDbPath: p.join('build', 'tag_repository_test_${const Uuid().v4()}'),
    );
    tagDatasource = TagDatasource(dbService: database);
  });

  group('TagRepository Integration Tests', () {
    test('TagRepository CRUD operations', () async {
      final logger = SimpleLoggerImpl(name: 'TagRepositoryTest');
      logger.info('Starting TagRepository test');

      logger.info('Database instance created');
      (await database.clearAll().run()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');

      final unitOfWork = SembastUnitOfWork(dbService: database);
      final tagRepository = TagRepositoryImpl(
        tagDatasource: tagDatasource,
        unitOfWork: unitOfWork,
      );

      // Check for zero tags
      var tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      var tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.isEmpty, true);

      // Add one tag
      final newTag = Tag(
        id: const Uuid().v4(),
        name: 'Test Tag',
        description: 'Test description',
        color: '#FF0000',
      );
      await tagRepository.create(item: newTag).run();

      // Verify count
      tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'Test Tag');

      // Update the tag
      final updatedTag = tags.first.copyWith(
        name: 'Updated Test Tag',
        description: 'Updated description',
      );
      await tagRepository.update(item: updatedTag).run();

      // Verify update
      tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'Updated Test Tag');
      expect(tags.first.description, 'Updated description');

      // Get tag by name
      var tagResult = await tagRepository
          .getByName(name: 'Updated Test Tag')
          .run();
      expect(tagResult.isRight(), true);
      var tag = tagResult.fold((l) => null, (r) => r);
      expect(tag, isNotNull);
      expect(tag!.name, 'Updated Test Tag');

      // Add another tag
      final secondTag = Tag(
        id: const Uuid().v4(),
        name: 'Second Tag',
        color: '#00FF00',
      );
      await tagRepository.create(item: secondTag).run();

      // Verify count increases
      tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 2);

      // Delete one tag
      await tagRepository.deleteById(item: updatedTag).run();

      // Verify count decreases
      tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'Second Tag');

      // Delete the last tag
      await tagRepository.deleteById(item: secondTag).run();

      // Verify zero tags
      tagsEither = await tagRepository.getAll().run();
      expect(tagsEither.isRight(), true);
      tags = tagsEither.fold((l) => <Tag>[], (r) => r);
      expect(tags.isEmpty, true);

      // Close database
      logger.info('Closing database');
      database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
