import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast_io.dart';
import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('SembastUnitOfWork', () {
    late SembastDatabase sembastDb;
    late SembastUnitOfWork unitOfWork;

    setUp(() {
      sembastDb = SembastDatabase();
      unitOfWork = SembastUnitOfWork(sembastDb: sembastDb);
    });

    group('run', () {
      test('returns Right with result on successful operation', () async {
        const expectedResult = 'test result';
        final result = await unitOfWork.run((Transaction txn) {
          expect(txn, isA<SembastTransaction>());
          return TaskEither.right(expectedResult);
        }).run();
        expect(result, Right(expectedResult));
      });

      test('returns Left with failure when operation fails', () async {
        final expectedFailure = DatabaseFailure('Operation failed');
        final result = await unitOfWork
            .run((Transaction txn) => TaskEither.left(expectedFailure))
            .run();
        expect(result, Left(expectedFailure));
      });

      test('returns Left with failure when operation throws', () async {
        final expectedFailure = ServiceFailure('Operation failed');
        final result = await unitOfWork
            .run(
              (Transaction txn) => TaskEither(() async {
                throw expectedFailure;
              }),
            )
            .run();
        expect(result, Left(expectedFailure));
      });
    });

    group('commit', () {
      test('returns Left with ServiceFailure', () async {
        // Act
        final result = await unitOfWork.commit().run();

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServiceFailure>());
          expect(
            failure.message,
            'Manual commit not supported in SembastUnitOfWork',
          );
        }, (_) => fail('Expected Left'));
      });
    });

    group('rollback', () {
      test('returns Left with ServiceFailure', () async {
        // Act
        final result = await unitOfWork.rollback().run();

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServiceFailure>());
          expect(
            failure.message,
            'Manual rollback not supported in SembastUnitOfWork',
          );
        }, (_) => fail('Expected Left'));
      });
    });
  });
}
