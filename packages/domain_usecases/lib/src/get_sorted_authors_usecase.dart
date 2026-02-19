import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// Use case for sorting a list of authors based on provided settings.
class GetSortedAuthorsUsecase with Loggable {
  final AuthorSortingService sortingService;

  /// Creates a GetSortedAuthorsUsecase with the required sorting service.
  GetSortedAuthorsUsecase({required this.sortingService});

  /// Sorts the given list of authors according to the sort settings.
  TaskEither<Failure, List<Author>> call(
    List<Author> authors,
    AuthorSortSettings settings,
  ) {
    return sortingService.sortAuthors(
      authors: authors,
      settings: settings,
      logger: logger,
    );
  }
}
