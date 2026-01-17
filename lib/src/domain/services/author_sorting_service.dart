import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for sorting authors
abstract class AuthorSortingService {
  /// Sorts authors based on the sort settings
  Either<Failure, List<Author>> sortAuthors({
    required List<Author> authors,
    required AuthorSortSettings settings,
  });
}
