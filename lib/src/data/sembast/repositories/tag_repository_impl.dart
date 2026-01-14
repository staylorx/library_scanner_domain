import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Implementation of tag repository using Sembast.
class TagRepositoryImpl implements AbstractTagRepository {
  final AbstractSembastService _databaseService;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl({required AbstractSembastService databaseService})
    : _databaseService = databaseService;

  final logger = Logger('TagRepositoryImpl');

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
    logger.info('TagRepositoryImpl: Entering getTags');
    try {
      final result = await _databaseService.getAll(collection: 'tags');
      return result.fold((failure) => Either.left(failure), (records) {
        final tags = <Tag>[];
        for (final record in records) {
          try {
            final model = TagModel.fromMap(map: record);
            tags.add(model.toEntity());
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        }
        logger.info(
          'TagRepositoryImpl: Success in getTags, fetched ${tags.length} tags',
        );
        logger.info(
          'TagRepositoryImpl: Output: ${tags.map((t) => t.name).toList()}',
        );
        logger.info('TagRepositoryImpl: Exiting getTags');
        return Either.right(tags);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Retrieves a tag by name.
  @override
  Future<Either<Failure, Tag?>> getTagByName({required String name}) async {
    logger.info('TagRepositoryImpl: Entering getTagByName with name: $name');
    try {
      // Compute slug from the input name for lookup
      final slug = _computeSlug(name);
      final result = await _databaseService.query(
        collection: 'tags',
        filter: {'slug': slug},
      );
      return result.fold((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          logger.info('TagRepositoryImpl: Tag with name $name not found');
          logger.info('TagRepositoryImpl: Output: null');
          logger.info('TagRepositoryImpl: Exiting getTagByName');
          return Either.right(null);
        }
        try {
          final model = TagModel.fromMap(map: records.first);
          logger.info('TagRepositoryImpl: Success, fetched tag ${model.name}');
          final tag = model.toEntity();
          logger.info('TagRepositoryImpl: Output: ${tag.name}');
          logger.info('TagRepositoryImpl: Exiting getTagByName');
          return Either.right(tag);
        } catch (e) {
          return Either.left(DataParsingFailure(e.toString()));
        }
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Retrieves a tag by handle.
  @override
  Future<Either<Failure, Tag?>> getTagByHandle({
    required TagHandle handle,
  }) async {
    logger.info(
      'TagRepositoryImpl: Entering getTagByHandle with handle: $handle',
    );
    try {
      final result = await _databaseService.query(
        collection: 'tags',
        filter: {'id': handle.toString()},
      );
      return result.fold((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          logger.info('TagRepositoryImpl: Tag with handle $handle not found');
          logger.info('TagRepositoryImpl: Output: null');
          logger.info('TagRepositoryImpl: Exiting getTagByHandle');
          return Either.right(null);
        }
        try {
          final model = TagModel.fromMap(map: records.first);
          logger.info('TagRepositoryImpl: Success, fetched tag ${model.name}');
          final tag = model.toEntity();
          logger.info('TagRepositoryImpl: Output: ${tag.name}');
          logger.info('TagRepositoryImpl: Exiting getTagByHandle');
          return Either.right(tag);
        } catch (e) {
          return Either.left(DataParsingFailure(e.toString()));
        }
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Retrieves tags by a list of names.
  @override
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  }) async {
    logger.info(
      'TagRepositoryImpl: Entering getTagsByNames with names: $names',
    );
    try {
      if (names.isEmpty) {
        logger.info('TagRepositoryImpl: names is empty, returning empty list');
        logger.info('TagRepositoryImpl: Output: []');
        logger.info('TagRepositoryImpl: Exiting getTagsByNames');
        return Either.right([]);
      }

      // Compute slugs for the names
      final slugs = names.map(_computeSlug).toList();
      final result = await _databaseService.query(
        collection: 'tags',
        filter: {
          'slug': {'\$in': slugs},
        },
      );
      return result.fold((failure) => Either.left(failure), (records) {
        final tags = <Tag>[];
        for (final record in records) {
          try {
            final model = TagModel.fromMap(map: record);
            tags.add(model.toEntity());
          } catch (e) {
            return Either.left(DataParsingFailure(e.toString()));
          }
        }
        logger.info(
          'TagRepositoryImpl: Success in getTagsByNames, fetched ${tags.length} tags',
        );
        logger.info(
          'TagRepositoryImpl: Output: ${tags.map((t) => t.name).toList()}',
        );
        logger.info('TagRepositoryImpl: Exiting getTagsByNames');
        return Either.right(tags);
      });
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  /// Adds a new tag to the database.
  @override
  Future<Either<Failure, TagHandle>> addTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering addTag with tag: ${tag.name}');
    try {
      // Check if a tag with the same slug already exists
      final queryResult = await _databaseService.query(
        collection: 'tags',
        filter: {'slug': tag.slug},
      );
      if (queryResult.isLeft()) {
        return Either.left(
          queryResult.getLeft().getOrElse(
            () => DatabaseFailure('Failed to check existing tag'),
          ),
        );
      }
      final records = queryResult.getRight().getOrElse(() => []);
      if (records.isNotEmpty) {
        logger.info(
          'TagRepositoryImpl: Tag with slug ${tag.slug} already exists',
        );
        return Either.left(
          ValidationFailure(
            'A tag with the slug "${tag.slug}" already exists.',
          ),
        );
      }

      final model = TagModel.fromEntity(tag);
      final result = await _databaseService.save(
        collection: 'tags',
        id: model.id,
        data: model.toMap(),
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('TagRepositoryImpl: Success added tag ${tag.name}');
        logger.info('TagRepositoryImpl: Exiting addTag');
        return Either.right(TagHandle(tag.name));
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
    logger.info('TagRepositoryImpl: Entering updateTag with tag: ${tag.name}');
    try {
      final model = TagModel.fromEntity(tag);
      logger.info(
        'TagRepositoryImpl: Created model for tag ${tag.name}, id: ${model.id}',
      );
      logger.info('TagRepositoryImpl: About to call database save');
      final result = await _databaseService.save(
        collection: 'tags',
        id: handle.toString(),
        data: model.toMap(),
      );
      logger.info('TagRepositoryImpl: Database save completed');
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('TagRepositoryImpl: Success updated tag ${tag.name}');
        logger.info('TagRepositoryImpl: Exiting updateTag');
        return Either.right(unit);
      });
    } catch (e) {
      logger.severe('TagRepositoryImpl: Exception in updateTag: $e');
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  /// Deletes a tag from the database.
  @override
  Future<Either<Failure, Unit>> deleteTag({required TagHandle handle}) async {
    logger.info('TagRepositoryImpl: Entering deleteTag with handle: $handle');
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
      if (queryResult.isLeft()) {
        return Either.left(
          queryResult.getLeft().getOrElse(
            () => DatabaseFailure('Query failed'),
          ),
        );
      }
      final bookMaps = queryResult.getRight().getOrElse(() => []);

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
          return Either.left(DatabaseWriteFailure('Failed to update book: $e'));
        }
      }

      // Delete the tag
      final deleteResult = await _databaseService.delete(
        collection: 'tags',
        id: handle.toString(),
      );
      return deleteResult.fold((failure) => Either.left(failure), (_) {
        logger.info(
          'TagRepositoryImpl: Success deleted tag and updated associated books',
        );
        logger.info('TagRepositoryImpl: Exiting deleteTag');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }
}
