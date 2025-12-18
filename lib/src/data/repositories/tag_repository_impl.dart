import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class TagRepositoryImpl implements ITagRepository {
  final DatabaseService _databaseService;

  TagRepositoryImpl({required DatabaseService databaseService}) : _databaseService = databaseService;

  final logger = DevLogger('TagRepositoryImpl');

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    logger.info('TagRepositoryImpl: Entering getTags');
    try {
      final result = await _databaseService.getAll('tags');
      return result.fold(
        (failure) => Either.left(failure),
        (records) {
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
        },
      );
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tag?>> getTagByName({required String name}) async {
    logger.info('TagRepositoryImpl: Entering getTagByName with name: $name');
    try {
      final result = await _databaseService.query('tags', {'name': name});
      return result.fold(
        (failure) => Either.left(failure),
        (records) {
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
        },
      );
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

      final result = await _databaseService.query('tags', {'name': {'\$in': names}});
      return result.fold(
        (failure) => Either.left(failure),
        (records) {
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
        },
      );
    } catch (e) {
      return Either.left(DatabaseReadFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering addTag with tag: ${tag.name}');
    try {
      final model = TagModel.fromEntity(tag);
      final result = await _databaseService.save('tags', tag.name, model.toMap());
      return result.fold(
        (failure) => Either.left(failure),
        (_) {
          logger.info('TagRepositoryImpl: Success added tag ${tag.name}');
          logger.info('TagRepositoryImpl: Exiting addTag');
          return Either.right(unit);
        },
      );
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering updateTag with tag: ${tag.name}');
    try {
      final model = TagModel.fromEntity(tag);
      final result = await _databaseService.save('tags', tag.name, model.toMap());
      return result.fold(
        (failure) => Either.left(failure),
        (_) {
          logger.info('TagRepositoryImpl: Success updated tag ${tag.name}');
          logger.info('TagRepositoryImpl: Exiting updateTag');
          return Either.right(unit);
        },
      );
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTag({required Tag tag}) async {
    logger.info('TagRepositoryImpl: Entering deleteTag with tag: ${tag.name}');
    try {
      final result = await _databaseService.delete('tags', tag.name);
      return result.fold(
        (failure) => Either.left(failure),
        (_) {
          logger.info('TagRepositoryImpl: Success deleted tag ${tag.name}');
          logger.info('TagRepositoryImpl: Exiting deleteTag');
          return Either.right(unit);
        },
      );
    } catch (e) {
      return Either.left(DatabaseWriteFailure(e.toString()));
    }
  }
}
