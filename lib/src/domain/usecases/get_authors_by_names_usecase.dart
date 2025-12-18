import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case for retrieving multiple authors by their names.
class GetAuthorsByNamesUsecase {
  final AbstractAuthorRepository authorRepository;

  GetAuthorsByNamesUsecase({required this.authorRepository});

  final logger = Logger('GetAuthorsByNamesUsecase');

  /// Retrieves multiple authors by their names.
  Future<Either<Failure, List<Author>>> call({
    required List<String> names,
  }) async {
    logger.info('GetAuthorsByNamesUseCase: Entering call with names: $names');
    final result = await authorRepository.getAuthorsByNames(names: names);
    logger.info('GetAuthorsByNamesUsecase: Success in call');
    return result.fold((failure) => Left(failure), (authors) {
      logger.info(
        'GetAuthorsByNamesUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      logger.info('GetAuthorsByNamesUsecase: Exiting call');
      return Right(authors);
    });
  }
}
