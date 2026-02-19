import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';

/// Service for sorting authors
abstract class AuthorSortingService {
  /// Sorts authors based on the sort settings
  TaskEither<Failure, List<Author>> sortAuthors({
    required List<Author> authors,
    required AuthorSortSettings settings,
    Logger? logger,
  });
}
