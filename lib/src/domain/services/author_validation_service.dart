import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for validating author data
abstract class AuthorValidationService {
  /// Validates an author entity
  TaskEither<Failure, Author> validate(Author author);
}
