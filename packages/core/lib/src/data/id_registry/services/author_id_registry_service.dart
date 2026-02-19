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
  TaskEither<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs) {
    return TaskEither.tryCatch(
      () async {
        _registry.register(idPairSet: idPairs);
        logger?.info(
          'Registered author ID pairs: ${idPairs.idPairs.length} pairs',
        );
        return unit;
      },
      (e, s) {
        if (e is DuplicateIdException) {
          logger?.warning('Failed to register author ID pairs: $e');
          return DuplicateIdFailure('Duplicate ID found in author pairs');
        } else if (e is ValidationException) {
          logger?.warning('Validation failed for author ID pairs: $e');
          return ValidationFailure('Invalid ID format in author pairs');
        } else {
          logger?.error('Unexpected error registering author ID pairs: $e');
          return RegistryFailure('Failed to register author ID pairs: $e');
        }
      },
    );
  }

  @override
  TaskEither<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs) {
    return TaskEither.tryCatch(
      () async {
        _registry.unregister(idPairSet: idPairs);
        logger?.info(
          'Unregistered author ID pairs: ${idPairs.idPairs.length} pairs',
        );
        return unit;
      },
      (e, s) {
        logger?.error('Unexpected error unregistering author ID pairs: $e');
        return RegistryFailure('Failed to unregister author ID pairs: $e');
      },
    );
  }

  @override
  TaskEither<Failure, bool> isRegistered(String idType, String idCode) {
    return TaskEither.tryCatch(
      () => _registry.isRegistered(idType: idType, idCode: idCode),
      (e, s) => RegistryFailure('Failed to check if ID is registered: $e'),
    );
  }

  @override
  TaskEither<Failure, String> generateId(String idType) {
    return TaskEither.tryCatch(
      () async {
        final id = await _registry.generateId(idType);
        logger?.info('Generated ID for type $idType: $id');
        return id;
      },
      (e, s) {
        logger?.error('Failed to generate ID for type $idType: $e');
        return RegistryFailure('Failed to generate ID: $e');
      },
    );
  }

  @override
  TaskEither<Failure, String> generateLocalId() {
    return generateId('local').map((id) {
      logger?.info('Generated local ID: $id');
      return id;
    });
  }

  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
  ) {
    logger?.info('Initializing author registry with existing data...');

    return TaskEither.traverseList(
      authorIdPairsList,
      (pairs) => registerAuthorIdPairs(pairs).orElse((failure) {
        logger?.warning(
          'Failed to register existing author ID pairs: $failure',
        );
        return TaskEither<Failure, Unit>.right(unit);
      }),
    ).map((_) {
      logger?.info('Author registry initialization completed');
      return unit;
    });
  }
}
