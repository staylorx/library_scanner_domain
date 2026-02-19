import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving a tag by ID.
class GetTagByIdUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagByIdUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves a tag by ID.
  TaskEither<Failure, Tag> call({required String id}) {
    logger?.info('GetTagByIdUsecase: Entering call with id: $id');
    return tagRepository.getById(id: id).map((tag) {
      logger?.info('GetTagByIdUsecase: Output: ${tag.name} (id: ${tag.id})');
      return tag;
    });
  }
}
