import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating a tag.
class UpdateTagUsecase with Loggable {
  final TagRepository tagRepository;

  UpdateTagUsecase({Logger? logger, required this.tagRepository});
  Future<Either<Failure, List<Tag>>> call({
    required TagHandle handle,
    required Tag tag,
  }) async {
    logger?.info(
      'UpdateTagUsecase: Entering call with handle: $handle and tag: ${tag.name}',
    );
    final updateEither = await tagRepository.updateTag(
      handle: handle,
      tag: tag,
    );
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
  }
}
