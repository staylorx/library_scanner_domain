import 'dart:io';

import 'package:datastore_isar/datastore_isar.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('IsarUnitOfWork', () {
    late IsarDatabase isarDb;
    late IsarUnitOfWork unitOfWork;
    late Directory tempDir;

    setUpAll(() async {
      // For pure-Dart tests, initialise Isar's native core once.
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('isar_test_');
      isarDb = IsarDatabase(
        directory: tempDir.path,
        name: 'test_${DateTime.now().millisecondsSinceEpoch}',
      );
      unitOfWork = IsarUnitOfWork(isarDb: isarDb);
    });

    tearDown(() async {
      await isarDb.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('run', () {
      test('passes an IsarTransactionUnitOfWork to the callback', () async {
        const expectedResult = 'test result';
        final result = await unitOfWork
            .run((UnitOfWork<TransactionHandle> txn) {
              expect(txn, isA<IsarTransactionUnitOfWork>());
              expect(txn.transactionHandle, isA<IsarTransactionHandle>());
              return TaskEither.right(expectedResult);
            })
            .run();
        expect(result, const Right(expectedResult));
      });

      test('returns Left on operation failure', () async {
        final expectedFailure = const DatabaseFailure('Operation failed');
        final result = await unitOfWork
            .run(
              (UnitOfWork<TransactionHandle> txn) =>
                  TaskEither.left(expectedFailure),
            )
            .run();
        expect(result, Left(expectedFailure));
      });

      test('returns Left when operation throws a Failure', () async {
        const expectedFailure = ServiceFailure('Operation failed');
        final result = await unitOfWork
            .run(
              (UnitOfWork<TransactionHandle> txn) => TaskEither(() async {
                throw expectedFailure;
              }),
            )
            .run();
        expect(result, const Left(expectedFailure));
      });

      test('wraps non-Failure exceptions as ServiceFailure', () async {
        final result = await unitOfWork
            .run(
              (UnitOfWork<TransactionHandle> txn) => TaskEither(() async {
                throw Exception('raw error');
              }),
            )
            .run();
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<ServiceFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('rolls back on failure (ACID proof)', () async {
        final db = await isarDb.isar;

        // Attempt to save an author, then force a failure — Isar must roll back.
        final result = await unitOfWork
            .run((UnitOfWork<TransactionHandle> txn) {
              return TaskEither.tryCatch(
                () async {
                  final schema = AuthorSchema()
                    ..stringId = 'rollback-test-id'
                    ..name = 'Rollback Author'
                    ..dataJson = '{"id":"rollback-test-id","name":"Rollback Author","businessIds":[]}';
                  await db.authorSchemas.put(schema);
                  // Force rollback.
                  throw const DatabaseFailure('Forced rollback');
                },
                (e, _) => e is Failure ? e : ServiceFailure(e.toString()),
              );
            })
            .run();

        // The operation must have failed.
        expect(result.isLeft(), true);

        // The author must NOT be in the database (Isar rolled back).
        final stored = await db.txn(
          () => db.authorSchemas.getByStringId('rollback-test-id'),
        );
        expect(stored, isNull);
      });

      test('commits on success (writes are durable)', () async {
        final db = await isarDb.isar;

        const authorId = 'commit-test-id';
        final result = await unitOfWork
            .run((UnitOfWork<TransactionHandle> txn) {
              return TaskEither.tryCatch(
                () async {
                  final schema = AuthorSchema()
                    ..stringId = authorId
                    ..name = 'Commit Author'
                    ..dataJson = '{"id":"$authorId","name":"Commit Author","businessIds":[]}';
                  await db.authorSchemas.put(schema);
                  return unit;
                },
                (e, _) => e is Failure ? e : ServiceFailure(e.toString()),
              );
            })
            .run();

        expect(result.isRight(), true);

        // The author must be in the database.
        final stored = await db.txn(
          () => db.authorSchemas.getByStringId(authorId),
        );
        expect(stored, isNotNull);
        expect(stored!.name, 'Commit Author');
      });
    });

    group('nested run', () {
      test('re-uses the same transaction handle', () async {
        IsarTransactionHandle? outerHandle;
        IsarTransactionHandle? innerHandle;

        await unitOfWork
            .run((UnitOfWork<TransactionHandle> outer) {
              outerHandle =
                  outer.transactionHandle as IsarTransactionHandle?;
              return outer.run((UnitOfWork<TransactionHandle> inner) {
                innerHandle =
                    inner.transactionHandle as IsarTransactionHandle?;
                return TaskEither.right(unit);
              });
            })
            .run();

        expect(outerHandle, isNotNull);
        expect(innerHandle, same(outerHandle));
      });
    });

    group('commit', () {
      test('always returns Left(ServiceFailure)', () async {
        final result = await unitOfWork.commit().run();
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServiceFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('rollback', () {
      test('always returns Left(ServiceFailure)', () async {
        final result = await unitOfWork.rollback().run();
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServiceFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });
  });
}
