import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:fpdart/fpdart.dart';
import 'package:slugify_string/slugify_string.dart';

/// Use case for updating an author.
class UpdateAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  UpdateAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Updates an existing author.
  /// Updates an existing author and returns the updated author.
  TaskEither<Failure, Author> call({
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
      return authorRepository.update(item: updatedAuthor).map((updated) {
        logger?.info('UpdateAuthorUsecase: Success in call');
        return updated;
      });
    });
  }
}
