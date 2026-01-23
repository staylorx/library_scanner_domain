import 'package:library_scanner_domain/library_scanner_domain.dart';

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
    return authorRepository.getAuthors().map((authors) {
      logger?.info(
        'GetAuthorsUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      return authors;
    });
  }
}
