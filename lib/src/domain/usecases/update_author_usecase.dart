import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:slugify_string/slugify_string.dart';

/// Use case for updating an author.
class UpdateAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  UpdateAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Updates an existing author.
  Future<Either<Failure, Unit>> call({
    required String id,
    required String name,
    String? biography,
    List<AuthorIdPair>? businessIds,
  }) async {
    logger?.info(
      'UpdateAuthorUsecase: Entering call with id: $id, name: $name',
    );
    final getEither = await authorRepository.getAuthorById(id: id);
    return getEither.fold((failure) => Left(failure), (existingAuthor) async {
      final slugId = AuthorIdPair(
        idType: AuthorIdType.local,
        idCode: Slugify(name).toString(),
      );
      final baseBusinessIds = businessIds ?? existingAuthor.businessIds;
      final updatedBusinessIds = [
        ...baseBusinessIds.where(
          (idPair) => idPair.idType != AuthorIdType.local,
        ),
        slugId,
      ];
      final updatedAuthor = existingAuthor.copyWith(
        name: name,
        biography: biography,
        businessIds: updatedBusinessIds,
      );
      final updateEither = await authorRepository.updateAuthor(
        author: updatedAuthor,
      );
      logger?.info('UpdateAuthorUsecase: Success in call');
      return updateEither.fold((failure) => Left(failure), (_) {
        return Right(unit);
      });
    });
  }
}
