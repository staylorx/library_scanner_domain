import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case responsible for deleting a tag from the repository.
///
/// This use case encapsulates the business logic for deleting a tag
/// by ID, including fetching the tag first to ensure it exists,
/// performing the deletion, and retrieving the updated list of tags.
/// It provides logging for debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class DeleteTagUsecase {
  final AbstractTagRepository tagRepository;

  DeleteTagUsecase(this.tagRepository);

  final logger = Logger('DeleteTagUsecase');

  /// Deletes a tag by ID and returns the updated list of tags.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the tag's ID for debugging purposes.
  /// 2. Fetches the tag by ID to verify existence.
  /// 3. If the tag exists, deletes it from the repository.
  /// 4. Retrieves the updated list of all tags.
  /// 5. Logs success and the resulting tag names.
  /// 6. Returns the complete list of tags after the deletion.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [id] - The unique identifier of the tag to be deleted.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all tags on the right.
  Future<Either<Failure, List<Tag>>> call({required String name}) async {
    logger.info('DeleteTagUsecase: Entering call with name: $name');
    final getTagsEither = await tagRepository.getTags();
    return getTagsEither.fold((failure) => Left(failure), (tags) async {
      final tag = tags.where((t) => t.name == name).firstOrNull;
      if (tag == null) {
        return Left(NotFoundFailure('Tag not found'));
      }
      final deleteEither = await tagRepository.deleteTag(tag: tag);
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedTags = tags.where((t) => t.name != name).toList();
        logger.info('DeleteTagUsecase: Success in call');
        logger.info(
          'DeleteTagUsecase: Output: ${updatedTags.map((t) => t.name).toList()}',
        );
        logger.info('DeleteTagUsecase: Exiting call');
        return Right(updatedTags);
      });
    });
  }
}
