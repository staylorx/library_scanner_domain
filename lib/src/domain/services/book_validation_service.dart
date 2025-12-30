import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for validating book data
abstract class AbstractBookValidationService {
  /// Validates a book entity
  Future<Either<Failure, Book>> validate(Book book);
}
