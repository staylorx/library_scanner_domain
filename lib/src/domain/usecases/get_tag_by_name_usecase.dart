import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for retrieving a tag by name.
class GetTagByNameUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagByNameUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves a tag by name.
  TaskEither<Failure, Tag> call({required String name}) {
    logger?.info('getByNameUsecase: Entering call with name: $name');
    return tagRepository.getByName(name: name).map((tag) {
      logger?.info('getByNameUsecase: Output: ${tag.name}');
      return tag;
    });
  }
}
