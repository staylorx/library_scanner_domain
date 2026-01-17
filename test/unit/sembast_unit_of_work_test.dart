import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_transaction.dart';
import 'package:library_scanner_domain/src/domain/repositories/unit_of_work.dart';
import 'package:library_scanner_domain/src/domain/services/database_service.dart';
import 'package:library_scanner_domain/src/utils/failure.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('SembastUnitOfWork', () {
    late MockDatabaseService mockDbService;
    late SembastUnitOfWork unitOfWork;

    setUp(() {
      mockDbService = MockDatabaseService();
      unitOfWork = SembastUnitOfWork(dbService: mockDbService);
    });

    group('run', () {
      test('returns Right with result on successful transaction', () async {
        // Arrange
        const expectedResult = 'test result';
        final mockTxn = 'mock transaction';

        when(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).thenAnswer((invocation) async {
          final operation =
              invocation.namedArguments[#operation]
                  as Future<Unit> Function(dynamic);
          await operation(mockTxn);
          return Right(unit);
        });

        // Act
        final result = await unitOfWork.run((Transaction txn) async {
          expect(txn, isA<SembastTransaction>());
          expect((txn as SembastTransaction).db, mockTxn);
          return expectedResult;
        });

        // Assert
        expect(result, Right(expectedResult));
        verify(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).called(1);
      });

      test('returns Left with failure on transaction failure', () async {
        // Arrange
        final expectedFailure = DatabaseFailure('Transaction failed');

        when(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).thenAnswer((_) async => Left(expectedFailure));

        // Act
        final result = await unitOfWork.run(
          (Transaction txn) async => 'result',
        );

        // Assert
        expect(result, Left(expectedFailure));
        verify(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).called(1);
      });

      test('returns Left with failure when operation throws', () async {
        // Arrange
        final expectedFailure = ServiceFailure('Operation failed');

        when(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).thenAnswer((invocation) async {
          final operation =
              invocation.namedArguments[#operation]
                  as Future<Unit> Function(dynamic);
          try {
            await operation('mockTxn');
            return Right(unit);
          } catch (e) {
            return Left(expectedFailure);
          }
        });

        // Act
        final result = await unitOfWork.run((Transaction txn) async {
          throw expectedFailure;
        });

        // Assert
        expect(result, Left(expectedFailure));
        verify(
          () => mockDbService.transaction(operation: any(named: 'operation')),
        ).called(1);
      });
    });

    group('commit', () {
      test('returns Left with ServiceFailure', () async {
        // Act
        final result = await unitOfWork.commit();

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
        final result = await unitOfWork.rollback();

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
