import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for validating book data
abstract class AbstractBookValidationService {
  /// Validates a book entity
  Future<Either<Failure, Book>> validate(Book book);
}

/// Concrete implementation of book validation service
class BookValidationService implements AbstractBookValidationService {
  final AbstractIdRegistryService _idRegistryService;

  BookValidationService({required AbstractIdRegistryService idRegistryService})
    : _idRegistryService = idRegistryService;

  @override
  Future<Either<Failure, Book>> validate(Book book) async {
    if (book.title.isEmpty) {
      return Left(ValidationFailure('Book title cannot be empty'));
    }
    if (book.authors.isEmpty) {
      return Left(ValidationFailure('Book must have at least one author'));
    }

    // Check for duplicate ID pairs
    for (final idPair in book.idPairs.idPairs) {
      final isRegistered = await _idRegistryService.isRegistered(
        idPair.idType.name,
        idPair.idCode,
      );
      if (isRegistered) {
        return Left(DuplicateIdFailure(
          'Book ID ${idPair.idType.displayName}:${idPair.idCode} is already registered',
        ));
      }
    }

    return Right(book);
  }
}
