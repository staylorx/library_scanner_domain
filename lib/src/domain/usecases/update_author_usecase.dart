import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:slugify_string/slugify_string.dart';

/// Use case for updating an author.
class UpdateAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  UpdateAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Updates an existing author.
  TaskEither<Failure, Unit> call({
    required String id,
    required String name,
    String? biography,
    List<AuthorIdPair>? businessIds,
  }) {
    logger?.info(
      'UpdateAuthorUsecase: Entering call with id: $id, name: $name',
    );
    return authorRepository.getById(id: id).flatMap((existingAuthor) {
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
      return authorRepository.update(item: updatedAuthor).map((_) => unit);
    });
  }
}
