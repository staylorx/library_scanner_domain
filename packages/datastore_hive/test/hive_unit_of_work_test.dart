import 'dart:io';

import 'package:datastore_hive/datastore_hive.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('HiveUnitOfWork', () {
    late HiveDatabase hiveDb;
    late HiveUnitOfWork unitOfWork;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      hiveDb = HiveDatabase(testDir: tempDir.path);
      unitOfWork = const HiveUnitOfWork();
    });

    tearDown(() async {
      await hiveDb.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('run', () {
      test('passes a HiveTransactionUnitOfWork to the callback', () async {
        const expectedResult = 'test result';
        final result = await unitOfWork
            .run((UnitOfWork<TransactionHandle> txn) {
              expect(txn, isA<HiveTransactionUnitOfWork>());
              expect(txn.transactionHandle, isA<HiveTransactionHandle>());
              return TaskEither.right(expectedResult);
            })
            .run();
        expect(result, Right(expectedResult));
      });

      test('returns Left on operation failure', () async {
        final expectedFailure = DatabaseFailure('Operation failed');
        final result = await unitOfWork
            .run(
              (UnitOfWork<TransactionHandle> txn) =>
                  TaskEither.left(expectedFailure),
            )
            .run();
        expect(result, Left(expectedFailure));
      });

      test('returns Left when operation throws a Failure', () async {
        final expectedFailure = ServiceFailure('Operation failed');
        final result = await unitOfWork
            .run(
              (UnitOfWork<TransactionHandle> txn) => TaskEither(() async {
                throw expectedFailure;
              }),
            )
            .run();
        expect(result, Left(expectedFailure));
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
    });

    group('nested run', () {
      test('re-uses the same transaction handle', () async {
        HiveTransactionHandle? outerHandle;
        HiveTransactionHandle? innerHandle;

        await unitOfWork
            .run((UnitOfWork<TransactionHandle> outer) {
              outerHandle =
                  outer.transactionHandle as HiveTransactionHandle?;
              // Calling run on the txn (not on unitOfWork) must re-use the same
              // handle rather than creating a new context.
              return outer.run((UnitOfWork<TransactionHandle> inner) {
                innerHandle =
                    inner.transactionHandle as HiveTransactionHandle?;
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
          (failure) {
            expect(failure, isA<ServiceFailure>());
            expect(
              failure.message,
              'Manual commit is not supported — Hive flushes writes individually.',
            );
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('rollback', () {
      test('always returns Left(ServiceFailure)', () async {
        final result = await unitOfWork.rollback().run();
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServiceFailure>());
            expect(
              failure.message,
              'Manual rollback is not supported — Hive has no transaction rollback.',
            );
          },
          (_) => fail('Expected Left'),
        );
      });
    });
  });
}
