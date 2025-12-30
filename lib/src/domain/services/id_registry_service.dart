import 'package:fpdart/fpdart.dart';
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
