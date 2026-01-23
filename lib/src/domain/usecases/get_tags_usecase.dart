import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for retrieving all tags.
class GetTagsUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagsUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves all tags.
  TaskEither<Failure, List<Tag>> call() {
    logger?.info('GetTagsUsecase: Entering call');
    return tagRepository.getTags().map((tags) {
      logger?.info(
        'GetTagsUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      return tags;
    });
  }
}
