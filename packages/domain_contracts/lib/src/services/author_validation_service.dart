import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for validating author data
abstract class AuthorValidationService {
  /// Validates an author entity
  TaskEither<Failure, Author> validate(Author author);
}
