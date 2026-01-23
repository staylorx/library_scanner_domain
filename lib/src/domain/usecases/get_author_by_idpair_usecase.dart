import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving an author by AuthorIdPair.
class GetAuthorByIdPairUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorByIdPairUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves an author by AuthorIdPair.
  Future<Either<Failure, Author>> call({
    required AuthorIdPair authorIdPair,
  }) async {
    logger?.info(
      'getAuthorByIdPairUsecase: Entering call with authorIdPair: $authorIdPair',
    );
    final result = await authorRepository.getAuthorByIdPair(
      authorIdPair: authorIdPair,
    );
    logger?.info('getAuthorByIdPairUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getAuthorByIdPairUsecase: Failure: $failure');
        return Left(failure);
      },
      (author) {
        logger?.info(
          'getAuthorByIdPairUsecase: Output: ${author.name} (businessIds: ${author.businessIds})',
        );
        return Right(author);
      },
    );
  }
}
