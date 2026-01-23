import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for sorting books
abstract class BookSortingService {
  /// Sorts books based on the sort settings
  TaskEither<Failure, List<Book>> sortBooks({
    required List<Book> books,
    required BookSortSettings settings,
  });
}
