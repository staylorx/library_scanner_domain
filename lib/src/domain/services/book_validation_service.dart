import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for validating book data
abstract class BookValidationService {
  /// Validates a book entity
  Future<Either<Failure, Book>> validate(Book book);
}
