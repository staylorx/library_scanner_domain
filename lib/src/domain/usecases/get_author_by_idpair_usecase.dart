import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving an author by AuthorIdPair.
class GetAuthorByIdPairUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorByIdPairUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves an author by AuthorIdPair.
  TaskEither<Failure, Author> call({required AuthorIdPair authorIdPair}) {
    logger?.info(
      'getAuthorByIdPairUsecase: Entering call with authorIdPair: $authorIdPair',
    );
    return authorRepository.getAuthorByIdPair(authorIdPair: authorIdPair).map((
      author,
    ) {
      logger?.info(
        'getAuthorByIdPairUsecase: Output: ${author.name} (businessIds: ${author.businessIds})',
      );
      return author;
    });
  }
}
