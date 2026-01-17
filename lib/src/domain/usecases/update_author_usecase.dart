import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating an author.
class UpdateAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  UpdateAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Updates an existing author.
  Future<Either<Failure, Unit>> call({
    required String id,
    required Author author,
  }) async {
    logger?.info(
      'UpdateAuthorUsecase: Entering call with id: $id and author: ${author.name}',
    );
    final updateEither = await authorRepository.updateAuthor(author: author);
    logger?.info('UpdateAuthorUsecase: Success in call');
    return updateEither.fold((failure) => Left(failure), (_) {
      return Right(unit);
    });
  }
}
