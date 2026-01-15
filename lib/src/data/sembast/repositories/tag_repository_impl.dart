import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of tag repository using Sembast.
class TagRepositoryImpl with Loggable implements TagRepository {
  final DatabaseService _databaseService;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl({required DatabaseService databaseService, Logger? logger})
    : _databaseService = databaseService;

  /// Computes a slug from a string.
  String _computeSlug(String input) {
    var slug = input
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9\s-]'),
          '',
        ) // Remove special chars except spaces and hyphens
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .trim();
    if (slug.startsWith('-')) slug = slug.substring(1);
    if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
    return slug;
  }

  /// Retrieves all tags from the database.
  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    logger?.info('TagRepositoryImpl: Entering getTags');
    return TaskEither.tryCatch(
      () async {
        final result = await _databaseService.getAll(collection: 'tags');
        return result.fold((failure) => throw failure, (records) {
          final tags = <Tag>[];
          for (final record in records) {
            final model = TagModel.fromMap(map: record);
            tags.add(model.toEntity());
          }
          logger?.info(
            'TagRepositoryImpl: Success in getTags, fetched ${tags.length} tags',
          );
          logger?.info(
            'TagRepositoryImpl: Output: ${tags.map((t) => t.name).toList()}',
          );
          logger?.info('TagRepositoryImpl: Exiting getTags');
          return tags;
        });
      },
      (error, stackTrace) =>
          error is Failure ? error : DatabaseReadFailure(error.toString()),
    ).run();
  }

  /// Retrieves a tag by name.
  @override
  Future<Either<Failure, Tag>> getByName({required String name}) async {
    logger?.info('TagRepositoryImpl: Entering getByName with name: $name');
    return TaskEither.tryCatch(
      () async {
        // Compute slug from the input name for lookup
        final slug = _computeSlug(name);
        final result = await _databaseService.query(
          collection: 'tags',
          filter: {'slug': slug},
        );
        return result.match(
          (failure) {
            logger?.warning('TagRepositoryImpl: Failed to query tag: $failure');
            throw failure;
          },
          (records) {
            if (records.isEmpty) {
              logger?.info('TagRepositoryImpl: Tag with name $name not found');
              logger?.info('TagRepositoryImpl: Exiting getByName');
              throw NotFoundFailure('Tag not found');
            }
            final model = TagModel.fromMap(map: records.first);
            logger?.info(
              'TagRepositoryImpl: Success, fetched tag ${model.name}',
            );
            final tag = model.toEntity();
            logger?.info('TagRepositoryImpl: Output: ${tag.name}');
            logger?.info('TagRepositoryImpl: Exiting getByName');
            return tag;
          },
        );
      },
      (error, stackTrace) =>
          error is Failure ? error : DatabaseReadFailure(error.toString()),
    ).run();
  }

  /// Retrieves a tag by handle.
  @override
  Future<Either<Failure, Tag>> getByHandle({required TagHandle handle}) async {
    logger?.info(
      'TagRepositoryImpl: Entering getByHandle with handle: $handle',
    );
    return TaskEither.tryCatch(
      () async {
        final result = await _databaseService.query(
          collection: 'tags',
          filter: {'id': handle.toString()},
        );
        return result.match(
          (failure) {
            logger?.warning('TagRepositoryImpl: Failed to query tag: $failure');
            throw failure;
          },
          (records) {
            if (records.isEmpty) {
              logger?.info(
                'TagRepositoryImpl: Tag with handle $handle not found',
              );
              logger?.info('TagRepositoryImpl: Exiting getByHandle');
              throw NotFoundFailure('Tag not found');
            }
            final model = TagModel.fromMap(map: records.first);
            logger?.info(
              'TagRepositoryImpl: Success, fetched tag ${model.name}',
            );
            final tag = model.toEntity();
            logger?.info('TagRepositoryImpl: Output: ${tag.name}');
            logger?.info('TagRepositoryImpl: Exiting getByHandle');
            return tag;
          },
        );
      },
      (error, stackTrace) =>
          error is Failure ? error : DatabaseReadFailure(error.toString()),
    ).run();
  }

  /// Retrieves tags by a list of names.
  @override
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  }) async {
    logger?.info(
      'TagRepositoryImpl: Entering getTagsByNames with names: $names',
    );
    final queryEither = await TaskEither.tryCatch(
      () async {
        if (names.isEmpty) return <Map<String, dynamic>>[];
        final slugs = names.map(_computeSlug).toList();
        final result = await _databaseService.query(
          collection: 'tags',
          filter: {
            'slug': {'\$in': slugs},
          },
        );
        return result.match((failure) => throw failure, (records) => records);
      },
      (error, stackTrace) =>
          error is Failure ? error : DatabaseReadFailure(error.toString()),
    ).run();
    return queryEither.match((failure) => Either.left(failure), (records) {
      final tags = <Tag>[];
      for (final record in records) {
        final model = TagModel.fromMap(map: record);
        tags.add(model.toEntity());
      }
      logger?.info(
        'TagRepositoryImpl: Success in getTagsByNames, fetched ${tags.length} tags',
      );
      logger?.info(
        'TagRepositoryImpl: Output: ${tags.map((t) => t.name).toList()}',
      );
      logger?.info('TagRepositoryImpl: Exiting getTagsByNames');
      return Either.right(tags);
    });
  }

  /// Adds a new tag to the database.
  @override
  Future<Either<Failure, TagHandle>> addTag({required Tag tag}) async {
    logger?.info('TagRepositoryImpl: Entering addTag with tag: ${tag.name}');
    try {
      // Check if a tag with the same slug already exists
      final queryResult = await _databaseService.query(
        collection: 'tags',
        filter: {'slug': tag.slug},
      );
      return queryResult.match((failure) => Either.left(failure), (
        records,
      ) async {
        if (records.isNotEmpty) {
          logger?.info(
            'TagRepositoryImpl: Tag with slug ${tag.slug} already exists',
          );
          return Either.left(
            ValidationFailure(
              'A tag with the slug "${tag.slug}" already exists.',
            ),
          );
        }

        final model = TagModel.fromEntity(tag);
        final saveResult = await _databaseService.save(
          collection: 'tags',
          id: model.id,
          data: model.toMap(),
        );
        return saveResult.match((failure) => Either.left(failure), (_) {
          logger?.info('TagRepositoryImpl: Success added tag ${tag.name}');
          logger?.info('TagRepositoryImpl: Exiting addTag');
          return Either.right(TagHandle(tag.name));
        });
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Updates an existing tag in the database.
  @override
  Future<Either<Failure, Unit>> updateTag({
    required TagHandle handle,
    required Tag tag,
  }) async {
    logger?.info('TagRepositoryImpl: Entering updateTag with tag: ${tag.name}');
    try {
      final newId = tag.name;
      if (handle.toString() != newId) {
        logger?.info('TagRepositoryImpl: Name changed, deleting old record');
        final deleteResult = await _databaseService.delete(
          collection: 'tags',
          id: handle.toString(),
        );
        return deleteResult.match((failure) => Either.left(failure), (_) async {
          final model = TagModel.fromEntity(tag);
          logger?.info(
            'TagRepositoryImpl: Created model for tag ${tag.name}, id: ${model.id}',
          );
          logger?.info('TagRepositoryImpl: About to call database save');
          final saveResult = await _databaseService.save(
            collection: 'tags',
            id: newId,
            data: model.toMap(),
          );
          logger?.info('TagRepositoryImpl: Database save completed');
          return saveResult.match((failure) => Either.left(failure), (_) {
            logger?.info('TagRepositoryImpl: Success updated tag ${tag.name}');
            logger?.info('TagRepositoryImpl: Exiting updateTag');
            return Either.right(unit);
          });
        });
      } else {
        final model = TagModel.fromEntity(tag);
        logger?.info(
          'TagRepositoryImpl: Created model for tag ${tag.name}, id: ${model.id}',
        );
        logger?.info('TagRepositoryImpl: About to call database save');
        final saveResult = await _databaseService.save(
          collection: 'tags',
          id: newId,
          data: model.toMap(),
        );
        logger?.info('TagRepositoryImpl: Database save completed');
        return saveResult.match((failure) => Either.left(failure), (_) {
          logger?.info('TagRepositoryImpl: Success updated tag ${tag.name}');
          logger?.info('TagRepositoryImpl: Exiting updateTag');
          return Either.right(unit);
        });
      }
    } catch (e) {
      logger?.error('TagRepositoryImpl: Exception in updateTag: $e');
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Deletes a tag from the database.
  @override
  Future<Either<Failure, Unit>> deleteTag({required TagHandle handle}) async {
    logger?.info('TagRepositoryImpl: Entering deleteTag with handle: $handle');
    try {
      // Query books that contain the tag
      final queryResult = await _databaseService.query(
        collection: 'books',
        filter: {
          'tagIds': {
            '\$in': [handle.toString()],
          },
        },
      );
      return queryResult.match((failure) => Either.left(failure), (
        bookMaps,
      ) async {
        // Update each book by removing the tag
        for (final bookMap in bookMaps) {
          try {
            final bookModel = BookModel.fromMap(map: bookMap);
            final updatedTagIds = List<String>.from(bookModel.tagIds)
              ..remove(handle.toString());
            final updatedModel = bookModel.copyWith(tagIds: updatedTagIds);
            final bookId = bookMap['id'] as String;
            final saveResult = await _databaseService.save(
              collection: 'books',
              id: bookId,
              data: updatedModel.toMap(),
            );
            if (saveResult.isLeft()) {
              return Either.left(
                saveResult.getLeft().getOrElse(
                  () => DatabaseFailure('Save failed'),
                ),
              );
            }
          } catch (e) {
            return Either.left(
              DatabaseWriteFailure('Failed to update book: $e'),
            );
          }
        }

        // Delete the tag
        final deleteResult = await _databaseService.delete(
          collection: 'tags',
          id: handle.toString(),
        );
        return deleteResult.match((failure) => Either.left(failure), (_) {
          logger?.info(
            'TagRepositoryImpl: Success deleted tag and updated associated books',
          );
          logger?.info('TagRepositoryImpl: Exiting deleteTag');
          return Either.right(unit);
        });
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }
}
