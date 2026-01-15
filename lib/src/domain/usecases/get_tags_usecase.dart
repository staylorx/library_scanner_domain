import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for retrieving all tags.
class GetTagsUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagsUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves all tags.
  Future<Either<Failure, List<Tag>>> call() async {
    logger?.info('GetTagsUsecase: Entering call');
    final result = await tagRepository.getTags();
    logger?.info('GetTagsUsecase: Success in call');
    return result.fold((failure) => Left(failure), (tags) {
      logger?.info(
        'GetTagsUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      return Right(tags);
    });
  }
}
