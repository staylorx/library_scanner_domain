import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:datastore_sembast/src/models/tag_model.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:path/path.dart' as p;
/// Convenience: extract the Sembast DatabaseClient from an active UnitOfWork.
SembastTransactionHandle? _handle(UnitOfWork<TransactionHandle> txn) =>
    txn.transactionHandle as SembastTransactionHandle?;

void main() {
  group('SembastUnitOfWork integration', () {
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

    tearDownAll(() => database.close());

    setUp(() async {
      // Start each test with an empty database.
      await database.clearAll().run();
    });

    // ─── Commit / success path ───────────────────────────────────────────────

    test('successful transaction commits changes', () async {
      final result = await unitOfWork.run((txn) {
        final tag = TagModel(
          id: 'tag-1',
          name: 'Tag 1',
          slug: 'tag-1',
          bookIds: [],
        );
        return tagDatasource.saveTag(tag, txn: _handle(txn)?.dbClient);
      }).run();

      expect(result.isRight(), true);

      final stored = await tagDatasource.getAllTags().run();
      stored.fold(
        (l) => fail('Expected right'),
        (tags) => expect(tags.length, 1),
      );
    });

    // ─── Rollback / failure path ─────────────────────────────────────────────

    test('failed transaction rolls back all writes', () async {
      final result = await unitOfWork.run((txn) {
        final tag = TagModel(
          id: 'tag-doomed',
          name: 'Doomed',
          slug: 'doomed',
          bookIds: [],
        );
        return tagDatasource
            .saveTag(tag, txn: _handle(txn)?.dbClient)
            .flatMap((_) => TaskEither.left(const ServiceFailure('Forced failure')));
      }).run();

      expect(result.isLeft(), true);

      // Nothing should have been persisted.
      final stored = await tagDatasource.getAllTags().run();
      stored.fold(
        (l) => fail('Expected right'),
        (tags) => expect(tags, isEmpty),
      );
    });

    // ─── Atomicity ───────────────────────────────────────────────────────────

    test('multiple writes in one transaction are atomic on success', () async {
      final result = await unitOfWork.run((txn) {
        final t1 = TagModel(id: 'a', name: 'A', slug: 'a', bookIds: []);
        final t2 = TagModel(id: 'b', name: 'B', slug: 'b', bookIds: []);
        return tagDatasource
            .saveTag(t1, txn: _handle(txn)?.dbClient)
            .flatMap((_) => tagDatasource.saveTag(t2, txn: _handle(txn)?.dbClient))
            .map((_) => unit);
      }).run();

      expect(result.isRight(), true);

      final stored = await tagDatasource.getAllTags().run();
      stored.fold(
        (l) => fail('Expected right'),
        (tags) => expect(tags.length, 2),
      );
    });

    test('partial writes are rolled back if the transaction fails', () async {
      final result = await unitOfWork.run((txn) {
        final t1 = TagModel(id: 'a', name: 'A', slug: 'a', bookIds: []);
        final t2 = TagModel(id: 'b', name: 'B', slug: 'b', bookIds: []);
        return tagDatasource
            .saveTag(t1, txn: _handle(txn)?.dbClient)
            .flatMap((_) => tagDatasource.saveTag(t2, txn: _handle(txn)?.dbClient))
            .flatMap((_) => TaskEither.left(const ServiceFailure('Boom')));
      }).run();

      expect(result.isLeft(), true);

      final stored = await tagDatasource.getAllTags().run();
      stored.fold(
        (l) => fail('Expected right'),
        (tags) => expect(tags, isEmpty),
      );
    });

    // ─── Nested run ──────────────────────────────────────────────────────────

    test('nested txn.run() re-uses the same transaction handle', () async {
      SembastTransactionHandle? outer;
      SembastTransactionHandle? inner;

      await unitOfWork.run((txn) {
        outer = txn.transactionHandle as SembastTransactionHandle?;
        return txn.run((nestedTxn) {
          inner = nestedTxn.transactionHandle as SembastTransactionHandle?;
          return TaskEither.right(unit);
        });
      }).run();

      expect(outer, isNotNull);
      expect(inner, same(outer),
          reason: 'Nested run must re-use the same SembastTransactionHandle');
    });

    // ─── Sequential transactions ──────────────────────────────────────────────

    test('sequential transactions each see the committed state', () async {
      // First transaction: write tag A.
      await unitOfWork.run((txn) {
        final t = TagModel(id: 'seq-1', name: 'Seq 1', slug: 'seq-1', bookIds: []);
        return tagDatasource.saveTag(t, txn: _handle(txn)?.dbClient);
      }).run();

      // Second transaction: write tag B — should see tag A already committed.
      final result = await unitOfWork.run((txn) {
        return tagDatasource.getAllTags().flatMap((tags) {
          // Tag A from the first transaction must be visible here.
          expect(tags.length, 1, reason: 'First transaction must be committed');
          final t = TagModel(id: 'seq-2', name: 'Seq 2', slug: 'seq-2', bookIds: []);
          return tagDatasource.saveTag(t, txn: _handle(txn)?.dbClient);
        });
      }).run();

      expect(result.isRight(), true);

      final stored = await tagDatasource.getAllTags().run();
      stored.fold(
        (l) => fail('Expected right'),
        (tags) => expect(tags.length, 2),
      );
    });

    // ─── Manual commit / rollback ─────────────────────────────────────────────

    test('commit() always returns Left (not supported by Sembast)', () async {
      final result = await unitOfWork.commit().run();
      expect(result.isLeft(), true);
    });

    test('rollback() always returns Left (not supported by Sembast)', () async {
      final result = await unitOfWork.rollback().run();
      expect(result.isLeft(), true);
    });
  });
}
