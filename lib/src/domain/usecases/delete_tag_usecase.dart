import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for deleting a tag from the repository.
class DeleteTagUsecase with Loggable {
  final TagRepository tagRepository;

  DeleteTagUsecase({Logger? logger, required this.tagRepository});

  /// Deletes a tag by id and returns the updated list of tags.
  TaskEither<Failure, List<Tag>> call({required String id}) {
    logger?.info('DeleteTagUsecase: Entering call with id: $id');
    return tagRepository.getById(id: id).flatMap((tag) {
      return tagRepository.deleteById(item: tag).flatMap((_) {
        return tagRepository.getAll().map((tags) {
          final updatedTags = tags.where((t) => t.id != id).toList();
          logger?.info('DeleteTagUsecase: Success in call');
          logger?.info(
            'DeleteTagUsecase: Output: ${updatedTags.map((t) => t.name).toList()}',
          );
          return updatedTags;
        });
      });
    });
  }
}
