import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for validating author data
abstract class AbstractAuthorValidationService {
  /// Validates an author entity
  Future<Either<Failure, Author>> validate(Author author);
}

/// Concrete implementation of author validation service
class AuthorValidationService implements AbstractAuthorValidationService {
  final AbstractIdRegistryService _idRegistryService;

  AuthorValidationService({required AbstractIdRegistryService idRegistryService})
    : _idRegistryService = idRegistryService;

  @override
  Future<Either<Failure, Author>> validate(Author author) async {
    if (author.name.isEmpty) {
      return Left(ValidationFailure('Author name cannot be empty'));
    }

    // Check for duplicate ID pairs
    for (final idPair in author.idPairs.idPairs) {
      final isRegistered = await _idRegistryService.isRegistered(
        idPair.idType.name,
        idPair.idCode,
      );
      if (isRegistered) {
        return Left(DuplicateIdFailure(
          'Author ID ${idPair.idType.displayName}:${idPair.idCode} is already registered',
        ));
      }
    }

    return Right(author);
  }
}