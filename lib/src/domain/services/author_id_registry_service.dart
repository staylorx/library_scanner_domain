import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../value_objects/author_id_pairs.dart';

/// Service for managing author ID uniqueness
abstract class AuthorIdRegistryService {
  /// Registers an author's ID pairs with the registry
  TaskEither<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs);

  /// Unregisters an author's ID pairs from the registry
  TaskEither<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs);

  /// Checks if an ID pair is already registered
  TaskEither<Failure, bool> isRegistered(String idType, String idCode);

  /// Generates a unique ID for the given type
  TaskEither<Failure, String> generateId(String idType);

  /// Generates a unique local ID (UUID)
  TaskEither<Failure, String> generateLocalId();

  /// Initializes the registry with existing author data
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
  );
}
