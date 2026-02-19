import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';

/// Implementation of author filtering service
class AuthorFilteringServiceImpl
    with Loggable
    implements AuthorFilteringService {
  @override
  TaskEither<Failure, List<Author>> filterAuthors({
    required List<Author> authors,
    required String searchQuery,
    Logger? logger,
  }) {
    if (searchQuery.isEmpty) {
      return TaskEither.right(authors);
    }

    final query = searchQuery.toLowerCase();
    final filteredAuthors = authors.where((author) {
      return author.name.toLowerCase().contains(query);
    }).toList();

    return TaskEither.right(filteredAuthors);
  }
}