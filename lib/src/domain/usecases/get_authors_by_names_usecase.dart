import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for retrieving multiple authors by their names.
class GetAuthorsByNamesUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorsByNamesUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves multiple authors by their names.
  Future<Either<Failure, List<Author>>> call({
    required List<String> names,
  }) async {
    logger?.info('GetAuthorsByNamesUseCase: Entering call with names: $names');
    final result = await authorRepository.getAuthorsByNames(names: names);
    logger?.info('GetAuthorsByNamesUsecase: Success in call');
    return result.fold((failure) => Left(failure), (authors) {
      logger?.info(
        'GetAuthorsByNamesUsecase: Output: ${authors.map((a) => a.name).toList()}',
      );
      logger?.info('GetAuthorsByNamesUsecase: Exiting call');
      return Right(authors);
    });
  }
}
