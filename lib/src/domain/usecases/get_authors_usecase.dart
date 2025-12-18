import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for retrieving all authors.
class GetAuthorsUsecase {
  final IAuthorRepository authorRepository;

  GetAuthorsUsecase(this.authorRepository);

  final logger = DevLogger('GetAuthorsUsecase');

  /// Retrieves all authors.
  Future<Either<Failure, List<Author>>> call() async {
    logger.info('GetAuthorsUsecase: Entering call');
    final result = await authorRepository.getAuthors();
    logger.info('GetAuthorsUsecase: Success in call');
    return result.fold((failure) => Left(failure), (authors) {
      logger.info(
        'GetAuthorsUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      logger.info('GetAuthorsUsecase: Exiting call');
      return Right(authors);
    });
  }
}
