import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Usecase for validating book data
class ValidateBookUsecase {
  final AbstractBookValidationService bookValidationService;

  ValidateBookUsecase({required this.bookValidationService});

  /// Validates a book entity
  Future<Either<Failure, Book>> call(Book book) async {
    return bookValidationService.validate(book);
  }
}
