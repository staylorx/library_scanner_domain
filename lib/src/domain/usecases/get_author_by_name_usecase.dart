import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for retrieving an author by name.
class GetAuthorByNameUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorByNameUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves an author by name.
  Future<Either<Failure, Author>> call({required String name}) async {
    logger?.info('getByNameUsecase: Entering call with name: $name');
    final result = await authorRepository.getByName(name: name);
    logger?.info('getByNameUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getByNameUsecase: Failure: $failure');
        return Left(failure);
      },
      (author) {
        logger?.info('getByNameUsecase: Output: ${author.name}');
        return Right(author);
      },
    );
  }
}
