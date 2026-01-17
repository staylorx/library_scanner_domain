import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating a tag.
class UpdateTagUsecase with Loggable {
  final TagRepository tagRepository;

  UpdateTagUsecase({Logger? logger, required this.tagRepository});
  Future<Either<Failure, List<Tag>>> call({
    required String id,
    required String name,
    String? description,
    String color = '#FF0000',
  }) async {
    logger?.info('UpdateTagUsecase: Entering call with id: $id, name: $name');
    final getEither = await tagRepository.getTagById(id: id);
    return getEither.fold((failure) => Left(failure), (existingTag) async {
      final updatedTag = existingTag.copyWith(
        name: name,
        description: description,
        color: color,
      );
      final updateEither = await tagRepository.updateTag(tag: updatedTag);
      return updateEither.fold((failure) => Future.value(Left(failure)), (
        _,
      ) async {
        final getEither = await tagRepository.getTags();
        logger?.info('UpdateTagUsecase: Success in call');
        return getEither.fold((failure) => Left(failure), (tags) {
          logger?.info(
            'UpdateTagUsecase: Output: ${tags.map((t) => t.name).toList()}',
          );
          return Right(tags);
        });
      });
    });
  }
}
