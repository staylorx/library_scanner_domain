import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for deleting a tag from the repository.
class DeleteTagUsecase with Loggable {
  final TagRepository tagRepository;

  DeleteTagUsecase({Logger? logger, required this.tagRepository});

  /// Deletes a tag by id and returns the updated list of tags.
  Future<Either<Failure, List<Tag>>> call({required String id}) async {
    logger?.info('DeleteTagUsecase: Entering call with id: $id');
    final getTagEither = await tagRepository.getTagById(id: id);
    return getTagEither.fold((failure) => Left(failure), (tag) async {
      final deleteEither = await tagRepository.deleteTag(tag: tag);
      return deleteEither.fold((failure) => Left(failure), (_) async {
        final getTagsEither = await tagRepository.getTags();
        return getTagsEither.fold((failure) => Left(failure), (tags) {
          final updatedTags = tags.where((t) => t.id != id).toList();
          logger?.info('DeleteTagUsecase: Success in call');
          logger?.info(
            'DeleteTagUsecase: Output: ${updatedTags.map((t) => t.name).toList()}',
          );
          return Right(updatedTags);
        });
      });
    });
  }
}
