import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving all authors.
class GetAuthorsUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorsUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves all authors.
  Future<Either<Failure, List<AuthorProjection>>> call() async {
    logger?.info('GetAuthorsUsecase: Entering call');
    final result = await authorRepository.getAuthors();
    logger?.info('GetAuthorsUsecase: Success in call');
    return result.fold((failure) => Left(failure), (authors) {
      logger?.info(
        'GetAuthorsUsecase: Output: ${authors.map((a) => a.author.name).toList()}',
      );
      return Right(authors);
    });
  }
}
