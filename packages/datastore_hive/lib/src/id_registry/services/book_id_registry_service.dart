import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:id_registry/id_registry.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';

/// Concrete implementation of book ID registry service using id_registry package
class BookIdRegistryServiceImpl with Loggable implements BookIdRegistryService {
  final IdRegistry _registry;

  BookIdRegistryServiceImpl({Logger? logger})
    : _registry = IdRegistry(storage: InMemoryIdStorage()) {
    _registry.registerIdTypeGenerator('local', IdGeneratorType.uuid);
    logger?.info('BookIdRegistryService initialized with in-memory storage');
  }

  @override
  TaskEither<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs) {
    return TaskEither.tryCatch(
      () async {
        _registry.register(idPairSet: idPairs);
        logger?.info(
          'Registered book ID pairs: ${idPairs.idPairs.length} pairs',
        );
        return unit;
      },
      (error, stackTrace) {
        if (error is DuplicateIdException) {
          logger?.warning('Failed to register book ID pairs: $error');
          return DuplicateIdFailure('Duplicate ID found in book pairs');
        } else if (error is ValidationException) {
          logger?.warning('Validation failed for book ID pairs: $error');
          return ValidationFailure('Invalid ID format in book pairs');
        } else {
          logger?.error('Unexpected error registering book ID pairs: $error');
          return RegistryFailure('Failed to register book ID pairs: $error');
        }
      },
    );
  }

  @override
  TaskEither<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs) {
    return TaskEither.tryCatch(
      () async {
        _registry.unregister(idPairSet: idPairs);
        logger?.info(
          'Unregistered book ID pairs: ${idPairs.idPairs.length} pairs',
        );
        return unit;
      },
      (error, stackTrace) {
        logger?.error('Unexpected error unregistering book ID pairs: $error');
        return RegistryFailure('Failed to unregister book ID pairs: $error');
      },
    );
  }

  @override
  TaskEither<Failure, bool> isRegistered(String idType, String idCode) {
    return TaskEither.tryCatch(
      () => _registry.isRegistered(idType: idType, idCode: idCode),
      (error, stackTrace) =>
          RegistryFailure('Failed to check registration: $error'),
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
      (error, stackTrace) =>
          RegistryFailure('Failed to generate ID: $error'),
    );
  }

  @override
  TaskEither<Failure, String> generateLocalId() {
    return TaskEither.tryCatch(
      () async {
        final id = await _registry.generateId('local');
        logger?.info('Generated local ID: $id');
        return id;
      },
      (error, stackTrace) =>
          RegistryFailure('Failed to generate local ID: $error'),
    );
  }

  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<BookIdPairs> bookIdPairsList,
  ) {
    return TaskEither.tryCatch(
      () async {
        logger?.info('Initializing book registry with existing data...');
        for (final bookIdPairs in bookIdPairsList) {
          final result = await registerBookIdPairs(bookIdPairs).run();
          if (result.isLeft()) {
            logger?.warning(
              'Failed to register existing book ID pairs: ${result.getLeft().getOrElse(() => RegistryFailure('Unknown error'))}',
            );
          }
        }
        logger?.info('Book registry initialization completed');
        return unit;
      },
      (error, stackTrace) =>
          RegistryFailure('Failed to initialize book registry: $error'),
    );
  }
}
