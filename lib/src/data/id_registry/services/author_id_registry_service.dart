import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_registry/id_registry.dart';

/// Concrete implementation of author ID registry service using id_registry package
class AuthorIdRegistryServiceImpl
    with Loggable
    implements AuthorIdRegistryService {
  final IdRegistry _registry;

  AuthorIdRegistryServiceImpl({Logger? logger})
    : _registry = IdRegistry(storage: InMemoryIdStorage()) {
    _registry.registerIdTypeGenerator('local', IdGeneratorType.uuid);
    logger?.info('AuthorIdRegistryService initialized with in-memory storage');
  }

  @override
  Either<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs) {
    try {
      _registry.register(idPairSet: idPairs);
      logger?.info(
        'Registered author ID pairs: ${idPairs.idPairs.length} pairs',
      );
      return Right(unit);
    } on DuplicateIdException catch (e) {
      logger?.warning('Failed to register author ID pairs: $e');
      return Left(DuplicateIdFailure('Duplicate ID found in author pairs'));
    } on ValidationException catch (e) {
      logger?.warning('Validation failed for author ID pairs: $e');
      return Left(ValidationFailure('Invalid ID format in author pairs'));
    } catch (e) {
      logger?.error('Unexpected error registering author ID pairs: $e');
      return Left(RegistryFailure('Failed to register author ID pairs: $e'));
    }
  }

  @override
  Either<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs) {
    try {
      _registry.unregister(idPairSet: idPairs);
      logger?.info(
        'Unregistered author ID pairs: ${idPairs.idPairs.length} pairs',
      );
      return Right(unit);
    } catch (e) {
      logger?.error('Unexpected error unregistering author ID pairs: $e');
      return Left(RegistryFailure('Failed to unregister author ID pairs: $e'));
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
    List<AuthorIdPairs> authorIdPairsList,
  ) async {
    try {
      logger?.info('Initializing author registry with existing data...');

      // Register all author ID pairs
      for (final authorIdPairs in authorIdPairsList) {
        final result = registerAuthorIdPairs(authorIdPairs);
        if (result.isLeft()) {
          // Log warning but continue - existing data might have duplicates
          logger?.warning(
            'Failed to register existing author ID pairs: ${result.getLeft().getOrElse(() => RegistryFailure('Unknown error'))}',
          );
        }
      }

      logger?.info('Author registry initialization completed');
      return Right(unit);
    } catch (e) {
      logger?.error(
        'Failed to initialize author registry with existing data: $e',
      );
      return Left(RegistryFailure('Failed to initialize author registry: $e'));
    }
  }
}
