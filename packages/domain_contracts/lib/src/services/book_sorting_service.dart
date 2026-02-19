import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for sorting books
abstract class BookSortingService {
  /// Sorts books based on the sort settings
  TaskEither<Failure, List<Book>> sortBooks({
    required List<Book> books,
    required BookSortSettings settings,
  });
}
