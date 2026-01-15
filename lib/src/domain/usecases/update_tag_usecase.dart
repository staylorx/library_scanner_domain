import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for updating an existing tag in the repository.
///
/// This use case encapsulates the business logic for updating a tag,
/// including validation through the repository layer and retrieving the
/// updated list of tags after successful update. It provides logging
/// for debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class UpdateTagUsecase {
  final TagRepository tagRepository;

  UpdateTagUsecase({required this.tagRepository});

  final logger = Logger('UpdateTagUsecase');

  /// Updates an existing tag in the repository and returns the updated list of tags.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the tag's name for debugging purposes.
  /// 2. Calls the repository to update the tag.
  /// 3. Retrieves the updated list of all tags.
  /// 4. Logs success and the resulting tag names.
  /// 5. Returns the complete list of tags after the update.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [tag] - The tag entity with updated information to be saved.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all tags on the right.
  Future<Either<Failure, List<Tag>>> call({required Tag tag}) async {
    logger.info('UpdateTagUsecase: Entering call with tag: ${tag.name}');
    final updateEither = await tagRepository.updateTag(
      handle: tag.id,
      tag: tag,
    );
    return updateEither.fold((failure) => Future.value(Left(failure)), (
      _,
    ) async {
      final getEither = await tagRepository.getTags();
      logger.info('UpdateTagUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (tags) {
        logger.info(
          'UpdateTagUsecase: Output: ${tags.map((t) => t.name).toList()}',
        );
        logger.info('UpdateTagUsecase: Exiting call');
        return Right(tags);
      });
    });
  }
}
