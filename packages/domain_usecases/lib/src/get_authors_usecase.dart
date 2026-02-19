import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving all authors.
class GetAuthorsUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorsUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves all authors.
  TaskEither<Failure, List<Author>> call() {
    logger?.info('GetAuthorsUsecase: Entering call');
    logger?.info('GetAuthorsUsecase: Success in call');
    return authorRepository.getAll().map((authors) {
      logger?.info(
        'GetAuthorsUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      return authors;
    });
  }
}
