import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new tag to the repository.
class AddTagUsecase with Loggable {
  final TagRepository tagRepository;

  AddTagUsecase({Logger? logger, required this.tagRepository});

  /// Adds a new tag and returns the updated list of tags.
  Future<Either<Failure, List<Tag>>> call({
    required String name,
    String? description,
    String color = '#FF0000',
  }) async {
    logger?.info('AddTagUsecase: Entering call with name: $name');
    final tag = Tag(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
    );
    final addEither = await tagRepository.addTag(tag: tag);
    return addEither.fold((failure) => Future.value(Left(failure)), (_) async {
      final getEither = await tagRepository.getTags();
      logger?.info('AddTagUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (tags) {
        logger?.info(
          'AddTagUsecase: Output: ${tags.map((t) => t.name).toList()}',
        );
        return Right(tags);
      });
    });
  }
}
