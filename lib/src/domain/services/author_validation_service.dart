import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for validating author data
abstract class AbstractAuthorValidationService {
  /// Validates an author entity
  Future<Either<Failure, Author>> validate(Author author);
}
