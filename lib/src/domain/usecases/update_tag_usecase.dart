import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating a tag.
class UpdateTagUsecase with Loggable {
  final TagRepository tagRepository;

  UpdateTagUsecase({Logger? logger, required this.tagRepository});
  TaskEither<Failure, Tag> call({
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
      return tagRepository.update(item: updatedTag).map((updated) {
        logger?.info('UpdateTagUsecase: Success in call');
        logger?.info('UpdateTagUsecase: Output: ${updated.name}');
        return updated;
      });
    });
  }
}
