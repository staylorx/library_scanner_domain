import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_registry/id_registry.dart';

/// Concrete implementation of book ID registry service using id_registry package
class BookIdRegistryServiceImpl with Loggable implements BookIdRegistryService {
  final IdRegistry _registry;

  BookIdRegistryServiceImpl({Logger? logger})
    : _registry = IdRegistry(storage: InMemoryIdStorage()) {
    _registry.registerIdTypeGenerator('local', IdGeneratorType.uuid);
    logger?.info('BookIdRegistryService initialized with in-memory storage');
  }

  @override
  Either<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs) {
    try {
      _registry.register(idPairSet: idPairs);
      logger?.info('Registered book ID pairs: ${idPairs.idPairs.length} pairs');
      return Right(unit);
    } on DuplicateIdException catch (e) {
      logger?.warning('Failed to register book ID pairs: $e');
      return Left(DuplicateIdFailure('Duplicate ID found in book pairs'));
    } on ValidationException catch (e) {
      logger?.warning('Validation failed for book ID pairs: $e');
      return Left(ValidationFailure('Invalid ID format in book pairs'));
    } catch (e) {
      logger?.error('Unexpected error registering book ID pairs: $e');
      return Left(RegistryFailure('Failed to register book ID pairs: $e'));
    }
  }

  @override
  Either<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs) {
    try {
      _registry.unregister(idPairSet: idPairs);
      logger?.info(
        'Unregistered book ID pairs: ${idPairs.idPairs.length} pairs',
      );
      return Right(unit);
    } catch (e) {
      logger?.error('Unexpected error unregistering book ID pairs: $e');
      return Left(RegistryFailure('Failed to unregister book ID pairs: $e'));
    }
  }

  @override
  Future<bool> isRegistered(String idType, String idCode) async {
    return _registry.isRegistered(idType: idType, idCode: idCode);
  }

  @override
  Future<Either<Failure, String>> generateId(String idType) async {
    try {
      final id = await _registry.generateId(idType);
      logger?.info('Generated ID for type $idType: $id');
      return Right(id);
    } catch (e) {
      logger?.error('Failed to generate ID for type $idType: $e');
      return Left(RegistryFailure('Failed to generate ID: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateLocalId() async {
    try {
      final id = await _registry.generateId('local');
      logger?.info('Generated local ID: $id');
      return Right(id);
    } catch (e) {
      logger?.error('Failed to generate local ID: $e');
      return Left(RegistryFailure('Failed to generate local ID: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> initializeWithExistingData(
    List<BookIdPairs> bookIdPairsList,
  ) async {
    try {
      logger?.info('Initializing book registry with existing data...');

      // Register all book ID pairs
      for (final bookIdPairs in bookIdPairsList) {
        final result = registerBookIdPairs(bookIdPairs);
        if (result.isLeft()) {
          // Log warning but continue - existing data might have duplicates
          logger?.warning(
            'Failed to register existing book ID pairs: ${result.getLeft().getOrElse(() => RegistryFailure('Unknown error'))}',
          );
        }
      }

      logger?.info('Book registry initialization completed');
      return Right(unit);
    } catch (e) {
      logger?.error(
        'Failed to initialize book registry with existing data: $e',
      );
      return Left(RegistryFailure('Failed to initialize book registry: $e'));
    }
  }
}
