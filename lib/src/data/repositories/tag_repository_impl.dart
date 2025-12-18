import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

class TagRepositoryImpl implements ITagRepository {
  final AbstractDatabaseService _databaseService;

  TagRepositoryImpl({required AbstractDatabaseService databaseService})
    : _databaseService = databaseService;

  final logger = Logger('TagRepositoryImpl');

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

  @override
  Future<Either<Failure, Tag?>> getTagByName({required String name}) async {
    logger.info('TagRepositoryImpl: Entering getTagByName with name: $name');
    try {
      final result = await _databaseService.query(
        collection: 'tags',
        filter: {'name': name},
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

  @override
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  }) async {
    logger.info('TagRepositoryImpl: Entering getTagsByNames with ids: $names');
    try {
      if (names.isEmpty) {
        logger.info('TagRepositoryImpl: ids is empty, returning empty list');
        logger.info('TagRepositoryImpl: Output: []');
        logger.info('TagRepositoryImpl: Exiting getTagsByNames');
        return Either.right([]);
      }

      final result = await _databaseService.query(
        collection: 'tags',
        filter: {
          'name': {'\$in': names},
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

  @override
  Future<Either<Failure, Unit>> addTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering addTag with tag: ${tag.name}');
    try {
      final model = TagModel.fromEntity(tag);
      final result = await _databaseService.save(
        collection: 'tags',
        id: tag.name,
        data: model.toMap(),
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('TagRepositoryImpl: Success added tag ${tag.name}');
        logger.info('TagRepositoryImpl: Exiting addTag');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering updateTag with tag: ${tag.name}');
    try {
      final model = TagModel.fromEntity(tag);
      final result = await _databaseService.save(
        collection: 'tags',
        id: tag.name,
        data: model.toMap(),
      );
      return result.fold((failure) => Either.left(failure), (_) {
        logger.info('TagRepositoryImpl: Success updated tag ${tag.name}');
        logger.info('TagRepositoryImpl: Exiting updateTag');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering deleteTag with tag: ${tag.name}');
    try {
      // Query books that contain the tag
      final queryResult = await _databaseService.query(
        collection: 'books',
        filter: {
          'tagIds': {
            '\$in': [tag.name],
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
            ..remove(tag.name);
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
        id: tag.name,
      );
      return deleteResult.fold((failure) => Either.left(failure), (_) {
        logger.info(
          'TagRepositoryImpl: Success deleted tag ${tag.name} and updated associated books',
        );
        logger.info('TagRepositoryImpl: Exiting deleteTag');
        return Either.right(unit);
      });
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }
}
