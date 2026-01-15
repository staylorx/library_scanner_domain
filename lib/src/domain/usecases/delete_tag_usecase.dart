import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for deleting a tag from the repository.
class DeleteTagUsecase with Loggable {
  final TagRepository tagRepository;

  DeleteTagUsecase({Logger? logger, required this.tagRepository});

  /// Deletes a tag by name and returns the updated list of tags.
  Future<Either<Failure, List<Tag>>> call({required String name}) async {
    logger?.info('DeleteTagUsecase: Entering call with name: $name');
    final getTagsEither = await tagRepository.getTags();
    return getTagsEither.fold((failure) => Left(failure), (tags) async {
      final tag = tags.where((t) => t.name == name).firstOrNull;
      if (tag == null) {
        return Left(NotFoundFailure('Tag not found'));
      }
      final deleteEither = await tagRepository.deleteTag(
        handle: TagHandle(tag.name),
      );
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedTags = tags.where((t) => t.name != name).toList();
        logger?.info('DeleteTagUsecase: Success in call');
        logger?.info(
          'DeleteTagUsecase: Output: ${updatedTags.map((t) => t.name).toList()}',
        );
        return Right(updatedTags);
      });
    });
  }
}
