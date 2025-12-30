import 'package:fpdart/fpdart.dart';
import 'package:id_registry/id_registry.dart';
import 'package:logging/logging.dart';

import '../../utils/failure.dart';
import '../value_objects/author_id_pairs.dart';
import '../value_objects/book_id_pairs.dart';

/// Abstract service for managing global ID uniqueness across the library
abstract class AbstractIdRegistryService {
  /// Registers an author's ID pairs with the global registry
  Either<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs);

  /// Unregisters an author's ID pairs from the global registry
  Either<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs);

  /// Registers a book's ID pairs with the global registry
  Either<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs);

  /// Unregisters a book's ID pairs from the global registry
  Either<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs);

  /// Checks if an ID pair is already registered
  Future<bool> isRegistered(String idType, String idCode);

  /// Generates a unique ID for the given type
  Future<Either<Failure, String>> generateId(String idType);

  /// Initializes the registry with existing data
  Future<Either<Failure, Unit>> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
    List<BookIdPairs> bookIdPairsList,
  );
}

/// Concrete implementation of ID registry service using id_registry package
class IdRegistryService implements AbstractIdRegistryService {
  final IdRegistry _registry;
  final Logger _logger = Logger('IdRegistryService');

  IdRegistryService()
      : _registry = IdRegistry(storage: InMemoryIdStorage()) {
    _logger.info('IdRegistryService initialized with in-memory storage');
  }

  @override
  Either<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs) {
    try {
      _registry.register(idPairSet: idPairs);
      _logger.info('Registered author ID pairs: ${idPairs.idPairs.length} pairs');
      return Right(unit);
    } on DuplicateIdException catch (e) {
      _logger.warning('Failed to register author ID pairs: $e');
      return Left(DuplicateIdFailure('Duplicate ID found in author pairs'));
    } on ValidationException catch (e) {
      _logger.warning('Validation failed for author ID pairs: $e');
      return Left(ValidationFailure('Invalid ID format in author pairs'));
    } catch (e) {
      _logger.severe('Unexpected error registering author ID pairs: $e');
      return Left(RegistryFailure('Failed to register author ID pairs: $e'));
    }
  }

  @override
  Either<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs) {
    try {
      _registry.unregister(idPairSet: idPairs);
      _logger.info('Unregistered author ID pairs: ${idPairs.idPairs.length} pairs');
      return Right(unit);
    } catch (e) {
      _logger.severe('Unexpected error unregistering author ID pairs: $e');
      return Left(RegistryFailure('Failed to unregister author ID pairs: $e'));
    }
  }

  @override
  Either<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs) {
    try {
      _registry.register(idPairSet: idPairs);
      _logger.info('Registered book ID pairs: ${idPairs.idPairs.length} pairs');
      return Right(unit);
    } on DuplicateIdException catch (e) {
      _logger.warning('Failed to register book ID pairs: $e');
      return Left(DuplicateIdFailure('Duplicate ID found in book pairs'));
    } on ValidationException catch (e) {
      _logger.warning('Validation failed for book ID pairs: $e');
      return Left(ValidationFailure('Invalid ID format in book pairs'));
    } catch (e) {
      _logger.severe('Unexpected error registering book ID pairs: $e');
      return Left(RegistryFailure('Failed to register book ID pairs: $e'));
    }
  }

  @override
  Either<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs) {
    try {
      _registry.unregister(idPairSet: idPairs);
      _logger.info('Unregistered book ID pairs: ${idPairs.idPairs.length} pairs');
      return Right(unit);
    } catch (e) {
      _logger.severe('Unexpected error unregistering book ID pairs: $e');
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
      _logger.info('Generated ID for type $idType: $id');
      return Right(id);
    } catch (e) {
      _logger.severe('Failed to generate ID for type $idType: $e');
      return Left(RegistryFailure('Failed to generate ID: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
    List<BookIdPairs> bookIdPairsList,
  ) async {
    try {
      _logger.info('Initializing registry with existing data...');

      // Register all author ID pairs
      for (final authorIdPairs in authorIdPairsList) {
        final result = registerAuthorIdPairs(authorIdPairs);
        if (result.isLeft()) {
          // Log warning but continue - existing data might have duplicates
          _logger.warning('Failed to register existing author ID pairs: ${result.getLeft().getOrElse(() => RegistryFailure('Unknown error'))}');
        }
      }

      // Register all book ID pairs
      for (final bookIdPairs in bookIdPairsList) {
        final result = registerBookIdPairs(bookIdPairs);
        if (result.isLeft()) {
          // Log warning but continue
          _logger.warning('Failed to register existing book ID pairs: ${result.getLeft().getOrElse(() => RegistryFailure('Unknown error'))}');
        }
      }

      _logger.info('Registry initialization completed');
      return Right(unit);
    } catch (e) {
      _logger.severe('Failed to initialize registry with existing data: $e');
      return Left(RegistryFailure('Failed to initialize registry: $e'));
    }
  }
}