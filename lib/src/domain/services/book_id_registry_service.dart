import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../value_objects/book_id_pairs.dart';

/// Abstract service for managing book ID uniqueness
abstract class AbstractBookIdRegistryService {
  /// Registers a book's ID pairs with the registry
  Either<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs);

  /// Unregisters a book's ID pairs from the registry
  Either<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs);

  /// Checks if an ID pair is already registered
  Future<bool> isRegistered(String idType, String idCode);

  /// Generates a unique ID for the given type
  Future<Either<Failure, String>> generateId(String idType);

  /// Generates a unique local ID (UUID)
  Future<Either<Failure, String>> generateLocalId();

  /// Initializes the registry with existing book data
  Future<Either<Failure, Unit>> initializeWithExistingData(
    List<BookIdPairs> bookIdPairsList,
  );
}
