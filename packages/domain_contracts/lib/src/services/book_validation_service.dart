import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for validating book data
abstract class BookValidationService {
  /// Validates a book entity
  TaskEither<Failure, Book> validate(Book book);
}
