import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Usecase for validating book data
class ValidateBookUsecase with Loggable {
  final BookValidationService bookValidationService;

  ValidateBookUsecase({required this.bookValidationService, Logger? logger}) {
    this.logger = logger;
  }

  /// Validates a book entity
  TaskEither<Failure, Book> call(Book book) {
    return bookValidationService.validate(book);
  }
}
