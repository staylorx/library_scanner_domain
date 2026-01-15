import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../value_objects/author_id_pairs.dart';

/// Abstract service for managing author ID uniqueness
abstract class AuthorIdRegistryService {
  /// Registers an author's ID pairs with the registry
  Either<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs);

  /// Unregisters an author's ID pairs from the registry
  Either<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs);

  /// Checks if an ID pair is already registered
  Future<bool> isRegistered(String idType, String idCode);

  /// Generates a unique ID for the given type
  Future<Either<Failure, String>> generateId(String idType);

  /// Generates a unique local ID (UUID)
  Future<Either<Failure, String>> generateLocalId();

  /// Initializes the registry with existing author data
  Future<Either<Failure, Unit>> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
  );
}
