import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating a tag.
class UpdateTagUsecase with Loggable {
  final TagRepository tagRepository;

  UpdateTagUsecase({Logger? logger, required this.tagRepository});
  Future<Either<Failure, List<Tag>>> call({required Tag tag}) async {
    logger?.info(
      'UpdateTagUsecase: Entering call with id: ${tag.id} and tag: ${tag.name}',
    );
    final updateEither = await tagRepository.updateTag(tag: tag);
    return updateEither.fold((failure) => Future.value(Left(failure)), (
      _,
    ) async {
      logger?.info('UpdateTagUsecase: Success in call');
      logger?.info('UpdateTagUsecase: Output: ${tag.name}');
      return Right([tag]);
    });
  }
}
