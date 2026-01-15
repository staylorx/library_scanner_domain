import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;

void main() {
  late DatabaseService database;
  late TagDatasource tagDatasource;

  setUpAll(() async {
    database = SembastDatabase(testDbPath: p.join('build', 'tag_test'));
    tagDatasource = TagDatasource(dbService: database);
  });

  group('Tag Integration Tests', () {
    test('Comprehensive Tag Integration Test', () async {
      final logger = SimpleLoggerImpl(name: 'TagTest');
      logger.info('Starting comprehensive tag test');

      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');

      final unitOfWork = SembastUnitOfWork(dbService: database);
      final tagRepository = TagRepositoryImpl(
        tagDatasource: tagDatasource,
        databaseService: database,
        unitOfWork: unitOfWork,
      );

      final getTagsUsecase = GetTagsUsecase(tagRepository: tagRepository);
      final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);
      final updateTagUsecase = UpdateTagUsecase(tagRepository: tagRepository);
      final deleteTagUsecase = DeleteTagUsecase(tagRepository: tagRepository);

      // Check for zero records
      var result = await getTagsUsecase();
      expect(result.isRight(), true);
      List<Tag> tags = result.fold((l) => <Tag>[], (r) => r);
      expect(tags.isEmpty, true);

      // Add one record
      final newTag = Tag(name: 'Test Tag', description: 'A test tag');
      await addTagUsecase.call(tag: newTag);

      // Verify count
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'Test Tag');

      // Update the record
      final updatedTag = tags.first.copyWith(
        name: 'Updated Test Tag',
        description: 'Updated description',
      );
      logger.info('About to call updateTagUsecase');
      final updateResult = await updateTagUsecase.call(
        handle: TagHandle.fromName(tags.first.name),
        tag: updatedTag,
      );
      logger.info('updateTagUsecase call completed');
      expect(updateResult.isRight(), true);
      final updatedTags = updateResult.fold((l) => <Tag>[], (r) => r);
      expect(updatedTags.length, 1);
      expect(updatedTags.first.name, 'Updated Test Tag');
      expect(updatedTags.first.description, 'Updated description');

      // Verify count remains the same
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.description, 'Updated description');

      // Add another record
      final secondTag = Tag(name: 'Second Tag', color: '#00FF00');
      await addTagUsecase.call(tag: secondTag);

      // Verify count increases
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 2);

      // Delete one record
      await deleteTagUsecase.call(name: updatedTag.name);

      // Verify count decreases
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => <Tag>[], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'Second Tag');

      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Duplicate Tag Name Test', () async {
      final logger = SimpleLoggerImpl(name: 'DuplicateTagTest');
      logger.info('Starting duplicate tag test');

      final database = SembastDatabase(
        testDbPath: p.join('build', 'tag_test_duplicate'),
      );
      final tagDatasource = TagDatasource(dbService: database);
      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');

      final unitOfWork = SembastUnitOfWork(dbService: database);
      final tagRepository = TagRepositoryImpl(
        tagDatasource: tagDatasource,
        databaseService: database,
        unitOfWork: unitOfWork,
      );
      final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);

      // Add first tag
      final tag = Tag(name: 'Unique Tag', description: 'A unique tag');
      var result = await addTagUsecase.call(tag: tag);
      expect(result.isRight(), true);

      // Try to add duplicate tag
      final duplicateTag = Tag(
        name: 'Unique Tag',
        description: 'Another description',
      );
      result = await addTagUsecase.call(tag: duplicateTag);
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure.runtimeType, ValidationFailure);
      expect(
        failure!.message,
        'A tag with the slug "unique-tag" already exists.',
      );

      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('Duplicate tag test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
