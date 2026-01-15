import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for fetching book metadata from external APIs.
abstract class BookApiService {
  /// Fetches book metadata by ISBN.
  Future<Either<Failure, BookMetadata?>> fetchBookByIsbn({
    required String isbn,
  });
}
