import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../value_objects/book_id_pairs.dart';

/// Service for managing book ID uniqueness
abstract class BookIdRegistryService {
  /// Registers a book's ID pairs with the registry
  TaskEither<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs);

  /// Unregisters a book's ID pairs from the registry
  TaskEither<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs);

  /// Checks if an ID pair is already registered
  TaskEither<Failure, bool> isRegistered(String idType, String idCode);

  /// Generates a unique ID for the given type
  TaskEither<Failure, String> generateId(String idType);

  /// Generates a unique local ID (UUID)
  TaskEither<Failure, String> generateLocalId();

  /// Initializes the registry with existing book data
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<BookIdPairs> bookIdPairsList,
  );
}
