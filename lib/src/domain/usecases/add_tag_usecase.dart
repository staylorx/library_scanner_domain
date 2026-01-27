import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:slugify_string/slugify_string.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new tag to the repository.
class AddTagUsecase with Loggable {
  final TagRepository tagRepository;
  final GetTagByNameUsecase getTagByNameUsecase;

  AddTagUsecase({
    Logger? logger,
    required this.tagRepository,
    required this.getTagByNameUsecase,
  });

  /// Adds a new tag and returns the created tag.
  TaskEither<Failure, Tag> call({
    required String name,
    String? description,
    String color = '#FF0000',
  }) {
    logger?.info('AddTagUsecase: Entering call with name: $name');
    return TaskEither(() async {
      final either = await getTagByNameUsecase.call(name: name).run();
      return either.fold(
        (failure) {
          if (failure is NotFoundFailure) {
            logger?.info('AddTagUsecase: Tag not found, proceeding to add');
            final tag = Tag(
              id: const Uuid().v4(),
              name: name,
              description: description,
              color: color,
            );
            return tagRepository.create(item: tag).map((created) {
              logger?.info('AddTagUsecase: Success in call');
              logger?.info('AddTagUsecase: Output: ${created.name}');
              return created;
            }).run();
          } else {
            logger?.info('AddTagUsecase: Unexpected failure: $failure');
            return left<Failure, Tag>(failure);
          }
        },
        (existingTag) {
          final slug = Slugify(name).toString();
          logger?.info(
            'AddTagUsecase: Duplicate tag found, returning ValidationFailure for slug: $slug',
          );
          return left<Failure, Tag>(
            ValidationFailure('A tag with the slug "$slug" already exists.'),
          );
        },
      );
    });
  }
}
