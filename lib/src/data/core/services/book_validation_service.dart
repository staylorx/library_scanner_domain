import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of book validation service
class BookValidationServiceImpl with Loggable implements BookValidationService {
  final BookIdRegistryService _idRegistryService;

  BookValidationServiceImpl({
    required BookIdRegistryService idRegistryService,
    Logger? logger,
  }) : _idRegistryService = idRegistryService;

  @override
  Future<Either<Failure, Book>> validate(Book book) async {
    if (book.title.isEmpty) {
      return Left(ValidationFailure('Book title cannot be empty'));
    }
    if (book.authors.isEmpty) {
      return Left(ValidationFailure('Book must have at least one author'));
    }

    // Check for duplicate ID pairs
    for (final idPair in book.businessIds) {
      final isRegistered = await _idRegistryService.isRegistered(
        idPair.idType.name,
        idPair.idCode,
      );
      if (isRegistered) {
        return Left(
          DuplicateIdFailure(
            'Book ID ${idPair.idType.displayName}:${idPair.idCode} is already registered',
          ),
        );
      }
    }

    return Right(book);
  }
}
