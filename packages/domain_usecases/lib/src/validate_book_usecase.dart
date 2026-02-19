import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

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
