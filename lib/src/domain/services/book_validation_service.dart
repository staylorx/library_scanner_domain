import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for validating book data
abstract class AbstractBookValidationService {
  /// Validates a book entity
  Either<Failure, Book> validate(Book book);
}

/// Concrete implementation of book validation service
class BookValidationService implements AbstractBookValidationService {
  @override
  Either<Failure, Book> validate(Book book) {
    if (book.title.isEmpty) {
      return Left(ValidationFailure('Book title cannot be empty'));
    }
    if (book.authors.isEmpty) {
      return Left(ValidationFailure('Book must have at least one author'));
    }
    return Right(book);
  }
}
