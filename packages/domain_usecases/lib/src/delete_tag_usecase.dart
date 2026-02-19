import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// Use case for deleting a tag from the repository.
class DeleteTagUsecase with Loggable {
  final TagRepository tagRepository;

  DeleteTagUsecase({Logger? logger, required this.tagRepository});

  /// Deletes a tag by id and returns the updated list of tags.
  /// Deletes a tag by id and returns `unit` on success.
  TaskEither<Failure, Unit> call({required String id}) {
    logger?.info('DeleteTagUsecase: Entering call with id: $id');
    return tagRepository.getById(id: id).flatMap((tag) {
      return tagRepository.deleteById(item: tag).map((_) {
        logger?.info('DeleteTagUsecase: Success in call');
        return unit;
      });
    });
  }
}
