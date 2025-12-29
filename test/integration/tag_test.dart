import 'dart:io';

import 'package:test/test.dart' show test, expect, group, Timeout;
import 'package:logging/logging.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  group('Tag Integration Tests', () {
    test('Comprehensive Tag Integration Test', () async {
      final logger = Logger('TagTest');
      logger.info('Starting comprehensive tag test');

      final database = SembastDatabase(testDbPath: null);
      logger.info('Database instance created');
      (await database.clearAll()).fold((l) => throw l, (r) => null);
      logger.info('Database cleared');

      final tagRepository = TagRepositoryImpl(databaseService: database);

      final getTagsUsecase = GetTagsUsecase(tagRepository: tagRepository);
      final addTagUsecase = AddTagUsecase(tagRepository: tagRepository);
      final updateTagUsecase = UpdateTagUsecase(tagRepository: tagRepository);
      final deleteTagUsecase = DeleteTagUsecase(tagRepository: tagRepository);

      // Check for zero records
      var result = await getTagsUsecase();
      expect(result.isRight(), true);
      var tags = result.fold((l) => [], (r) => r);
      expect(tags.isEmpty, true);

      // Add one record
      final newTag = Tag(name: 'Test Tag', description: 'A test tag');
      await addTagUsecase.call(tag: newTag);

      // Verify count
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => [], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'test tag'); // lowercase

      // Update the record
      final updatedTag = newTag.copyWith(
        name: 'Updated Test Tag',
        description: 'Updated description',
      );
      logger.info('About to call updateTagUsecase');
      final updateResult = await updateTagUsecase.call(
        oldTag: newTag,
        newTag: updatedTag,
      );
      logger.info('updateTagUsecase call completed');
      expect(updateResult.isRight(), true);
      final updatedTags = updateResult.fold((l) => [], (r) => r);
      expect(updatedTags.length, 1);
      expect(updatedTags.first.name, 'updated test tag');
      expect(updatedTags.first.description, 'Updated description');

      // Verify count remains the same
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => [], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.description, 'Updated description');

      // Add another record
      final secondTag = Tag(name: 'Second Tag', color: '#00FF00');
      await addTagUsecase.call(tag: secondTag);

      // Verify count increases
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => [], (r) => r);
      expect(tags.length, 2);

      // Delete one record
      await deleteTagUsecase.call(name: updatedTag.name);

      // Verify count decreases
      result = await getTagsUsecase();
      expect(result.isRight(), true);
      tags = result.fold((l) => [], (r) => r);
      expect(tags.length, 1);
      expect(tags.first.name, 'second tag');

      // Close database
      logger.info('Closing database');
      await database.close();
      logger.info('Test completed');
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
