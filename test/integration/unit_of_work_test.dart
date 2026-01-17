import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/storage/tag_datasource.dart';
import 'package:library_scanner_domain/src/data/core/models/tag_model.dart';
import 'package:library_scanner_domain/src/domain/services/database_service.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Unit of Work Integration Tests', () {
    late DatabaseService database;
    late TagDatasource tagDatasource;
    late SembastUnitOfWork unitOfWork;

    setUpAll(() async {
      database = SembastDatabase(
        testDbPath: p.join('build', 'uow_integration_test'),
      );
      tagDatasource = TagDatasource(dbService: database);
      unitOfWork = SembastUnitOfWork(dbService: database);
      await database.clearAll();
    });

    tearDownAll(() async {
      await database.close();
    });

    setUp(() async {
      // Clear database before each test
      await database.clearAll();
    });

    test('Successful transaction commits database changes', () async {
      // Verify no tags initially
      final initialResult = await tagDatasource.getAllTags();
      expect(initialResult.isRight(), true);
      initialResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );

      // Run transaction that saves a tag
      final result = await unitOfWork.run((txn) async {
        final tagModel = TagModel(
          id: 'test-tag',
          name: 'Test Tag',
          slug: 'test-tag',
          bookIdPairs: [],
        );
        final saveResult = await tagDatasource.saveTag(
          tagModel,
          db: (txn as dynamic).db,
        );
        expect(saveResult.isRight(), true);
        return 'success';
      });

      expect(result.isRight(), true);
      result.fold((l) => fail('Expected right'), (r) => expect(r, 'success'));

      // Verify tag was committed
      final verifyResult = await tagDatasource.getAllTags();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.length, 1),
      );
    });

    test('Failed transaction rolls back database changes', () async {
      // Verify no tags initially
      final initialResult = await tagDatasource.getAllTags();
      expect(initialResult.isRight(), true);
      initialResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );

      // Run transaction that saves tag but then fails
      final result = await unitOfWork.run((txn) async {
        final tagModel = TagModel(
          id: 'test-tag',
          name: 'Test Tag',
          slug: 'test-tag',
          bookIdPairs: [],
        );
        final saveResult = await tagDatasource.saveTag(
          tagModel,
          db: (txn as dynamic).db,
        );
        expect(saveResult.isRight(), true);

        // Simulate failure after save
        throw Exception('Test failure');
      });

      expect(result.isLeft(), true);

      // Verify tag was rolled back (should be empty)
      final verifyResult = await tagDatasource.getAllTags();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('Multiple operations in transaction are atomic', () async {
      final result = await unitOfWork.run((txn) async {
        // Save first tag
        final tagModel1 = TagModel(
          id: 'tag-1',
          name: 'Tag 1',
          slug: 'tag-1',
          bookIdPairs: [],
        );
        await tagDatasource.saveTag(tagModel1, db: (txn as dynamic).db);

        // Save second tag
        final tagModel2 = TagModel(
          id: 'tag-2',
          name: 'Tag 2',
          slug: 'tag-2',
          bookIdPairs: [],
        );
        await tagDatasource.saveTag(tagModel2, db: (txn as dynamic).db);

        return 'success';
      });

      expect(result.isRight(), true);

      // Verify both tags were committed
      final verifyResult = await tagDatasource.getAllTags();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.length, 2),
      );
    });

    test('Transaction failure rolls back multiple operations', () async {
      final result = await unitOfWork.run((txn) async {
        // Save first tag
        final tagModel1 = TagModel(
          id: 'tag-1',
          name: 'Tag 1',
          slug: 'tag-1',
          bookIdPairs: [],
        );
        await tagDatasource.saveTag(tagModel1, db: (txn as dynamic).db);

        // Save second tag
        final tagModel2 = TagModel(
          id: 'tag-2',
          name: 'Tag 2',
          slug: 'tag-2',
          bookIdPairs: [],
        );
        await tagDatasource.saveTag(tagModel2, db: (txn as dynamic).db);

        // Fail after both saves
        throw Exception('Transaction failure');
      });

      expect(result.isLeft(), true);

      // Verify all changes were rolled back
      final verifyResult = await tagDatasource.getAllTags();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('Manual commit returns failure', () async {
      final result = await unitOfWork.commit();
      expect(result.isLeft(), true);
    });

    test('Manual rollback returns failure', () async {
      final result = await unitOfWork.rollback();
      expect(result.isLeft(), true);
    });
  });
}
