import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for retrieving all tags.
class GetTagsUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagsUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves all tags.
  TaskEither<Failure, List<Tag>> call() {
    logger?.info('GetTagsUsecase: Entering call');
    return tagRepository.getAll().map((tags) {
      logger?.info(
        'GetTagsUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      return tags;
    });
  }
}
