import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:datastore_sembast/src/models/tag_model.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Unit of Work Integration Tests', () {
    late SembastDatabase database;
    late TagDatasource tagDatasource;
    late SembastUnitOfWork unitOfWork;

    setUpAll(() async {
      database = SembastDatabase(
        testDbPath: p.join('build', 'uow_integration_test'),
      );
      tagDatasource = TagDatasource(sembastDb: database);
      unitOfWork = SembastUnitOfWork(sembastDb: database);
      await database.clearAll().run();
    });

    tearDownAll(() async {
      database.close();
    });

    setUp(() async {
      // Clear database before each test
      await database.clearAll().run();
    });

    test('Successful transaction commits database changes', () async {
      // Verify no tags initially
      final initialResult = await tagDatasource.getAllTags().run();
      expect(initialResult.isRight(), true);
      initialResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );

      // Run transaction that saves a tag
      final result = await unitOfWork.run((UnitOfWork<Object?> txn) {
        return TaskEither.tryCatch(() async {
          final tagModel = TagModel(
            id: 'test-tag',
            name: 'Test Tag',
            slug: 'test-tag',
            bookIds: [],
          );
          final saveResult = await tagDatasource
              .saveTag(
                tagModel,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();
          expect(saveResult.isRight(), true);
          return 'success';
        }, (error, stack) => ServiceFailure(error.toString()));
      }).run();

      expect(result.isRight(), true);
      result.fold((l) => fail('Expected right'), (r) => expect(r, 'success'));

      // Verify tag was committed
      final verifyResult = await tagDatasource.getAllTags().run();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.length, 1),
      );
    });

    test('Failed transaction rolls back database changes', () async {
      // Verify no tags initially
      final initialResult = await tagDatasource.getAllTags().run();
      expect(initialResult.isRight(), true);
      initialResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );

      // Run transaction that saves tag but then fails
      final result = await unitOfWork.run((UnitOfWork<Object?> txn) {
        return TaskEither.tryCatch(() async {
          final tagModel = TagModel(
            id: 'test-tag',
            name: 'Test Tag',
            slug: 'test-tag',
            bookIds: [],
          );
          final saveResult = await tagDatasource
              .saveTag(
                tagModel,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();
          expect(saveResult.isRight(), true);

          // Simulate failure after save
          throw Exception('Test failure');
        }, (error, stack) => ServiceFailure(error.toString()));
      }).run();

      expect(result.isLeft(), true);

      // Verify tag was rolled back (should be empty)
      final verifyResult = await tagDatasource.getAllTags().run();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('Multiple operations in transaction are atomic', () async {
      final result = await unitOfWork.run((UnitOfWork<Object?> txn) {
        return TaskEither.tryCatch(() async {
          // Save first tag
          final tagModel1 = TagModel(
            id: 'tag-1',
            name: 'Tag 1',
            slug: 'tag-1',
            bookIds: [],
          );
          await tagDatasource
              .saveTag(
                tagModel1,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();

          // Save second tag
          final tagModel2 = TagModel(
            id: 'tag-2',
            name: 'Tag 2',
            slug: 'tag-2',
            bookIds: [],
          );
          await tagDatasource
              .saveTag(
                tagModel2,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();

          return 'success';
        }, (error, stack) => ServiceFailure(error.toString()));
      }).run();

      expect(result.isRight(), true);

      // Verify both tags were committed
      final verifyResult = await tagDatasource.getAllTags().run();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.length, 2),
      );
    });

    test('Transaction failure rolls back multiple operations', () async {
      final result = await unitOfWork.run((UnitOfWork<Object?> txn) {
        return TaskEither.tryCatch(() async {
          // Save first tag
          final tagModel1 = TagModel(
            id: 'tag-1',
            name: 'Tag 1',
            slug: 'tag-1',
            bookIds: [],
          );
          await tagDatasource
              .saveTag(
                tagModel1,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();

          // Save second tag
          final tagModel2 = TagModel(
            id: 'tag-2',
            name: 'Tag 2',
            slug: 'tag-2',
            bookIds: [],
          );
          await tagDatasource
              .saveTag(
                tagModel2,
                txn: (txn.transactionHandle as SembastTransactionHandle?)?.dbClient,
              )
              .run();

          // Fail after both saves
          throw Exception('Transaction failure');
        }, (error, stack) => ServiceFailure(error.toString()));
      }).run();

      expect(result.isLeft(), true);

      // Verify all changes were rolled back
      final verifyResult = await tagDatasource.getAllTags().run();
      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (l) => fail('Expected right'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('Manual commit returns failure', () async {
      final result = await unitOfWork.commit().run();
      expect(result.isLeft(), true);
    });

    test('Manual rollback returns failure', () async {
      final result = await unitOfWork.rollback().run();
      expect(result.isLeft(), true);
    });
  });
}
