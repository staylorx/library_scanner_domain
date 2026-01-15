import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for adding a new tag to the repository.
class AddTagUsecase with Loggable {
  final TagRepository tagRepository;

  AddTagUsecase({Logger? logger, required this.tagRepository});

  /// Adds a new tag to the repository and returns the updated list of tags.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the tag's name for debugging purposes.
  /// 2. Calls the repository to add the tag.
  /// 3. Retrieves the updated list of all tags.
  /// 4. Logs success and the resulting tag names.
  /// 5. Returns the complete list of tags after the addition.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [tag] - The tag entity to be added to the repository.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all tags on the right.
  Future<Either<Failure, List<Tag>>> call({required Tag tag}) async {
    logger?.info('AddTagUsecase: Entering call with tag: ${tag.name}');
    final addEither = await tagRepository.addTag(tag: tag);
    return addEither.fold((failure) => Future.value(Left(failure)), (_) async {
      final getEither = await tagRepository.getTags();
      logger?.info('AddTagUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (tags) {
        logger?.info(
          'AddTagUsecase: Output: ${tags.map((t) => t.name).toList()}',
        );
        logger?.info('AddTagUsecase: Exiting call');
        return Right(tags);
      });
    });
  }
}
