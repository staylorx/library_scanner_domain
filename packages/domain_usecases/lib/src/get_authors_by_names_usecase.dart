import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for retrieving multiple authors by their names.
class GetAuthorsByNamesUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorsByNamesUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves multiple authors by their names.
  TaskEither<Failure, List<Author>> call({required List<String> names}) {
    logger?.info('GetAuthorsByNamesUseCase: Entering call with names: $names');
    return authorRepository.getAuthorsByNames(names: names).map((authors) {
      logger?.info(
        'GetAuthorsByNamesUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      return authors;
    });
  }
}
