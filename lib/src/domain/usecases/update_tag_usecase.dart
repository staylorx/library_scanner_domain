import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

// TODO: possible UI improvement is to return just Tag instead of List<Tag>

/// Use case for updating a tag.
class UpdateTagUsecase with Loggable {
  final TagRepository tagRepository;

  UpdateTagUsecase({Logger? logger, required this.tagRepository});
  TaskEither<Failure, List<Tag>> call({
    required String id,
    required String name,
    String? description,
    String color = '#FF0000',
  }) {
    logger?.info('UpdateTagUsecase: Entering call with id: $id, name: $name');
    return tagRepository.getById(id: id).flatMap((existingTag) {
      final updatedTag = existingTag.copyWith(
        name: name,
        description: description,
        color: color,
      );
      return tagRepository.update(item: updatedTag).flatMap((_) {
        return tagRepository.getAll().map((tags) {
          logger?.info('UpdateTagUsecase: Success in call');
          logger?.info(
            'UpdateTagUsecase: Output: ${tags.map((t) => t.name).toList()}',
          );
          return tags;
        });
      });
    });
  }
}
