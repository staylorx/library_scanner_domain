import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of tag repository using Sembast.
class TagRepositoryImpl with Loggable implements TagRepository {
  final TagDatasource _tagDatasource;
  final UnitOfWork _unitOfWork;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl({
    required TagDatasource tagDatasource,
    required DatabaseService databaseService,
    required UnitOfWork unitOfWork,
    Logger? logger,
  }) : _tagDatasource = tagDatasource,
       _unitOfWork = unitOfWork;

  /// Retrieves all tags from the database.
  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    logger?.info('Entering getTags');
    final result = await _tagDatasource.getAllTags();
    return result.fold(
      (failure) {
        logger?.warning('Failed to get tags: ${failure.message}');
        return Either.left(failure);
      },
      (models) {
        logger?.info('Successfully retrieved ${models.length} tags');
        final tags = models.map((model) => model.toEntity()).toList();
        return Either.right(tags);
      },
    );
  }

  /// Retrieves a tag by name.
  @override
  Future<Either<Failure, Tag>> getByName({required String name}) async {
    logger?.info('Entering getByName with name: $name');
    final result = await _tagDatasource.getTagByName(name);
    return result.fold((failure) => Either.left(failure), (model) {
      if (model == null) {
        return Either.left(NotFoundFailure('Tag not found'));
      }
      logger?.info('Success, fetched tag ${model.name}');
      return Either.right(model.toEntity());
    });
  }

  /// Retrieves tags by a list of names.
  @override
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  }) async {
    logger?.info('Entering getTagsByNames with names: $names');
    if (names.isEmpty) {
      logger?.info('names is empty, returning empty list');
      return Either.right([]);
    }
    final result = await _tagDatasource.getTagsByNames(names);
    return result.fold((failure) => Either.left(failure), (models) {
      final tags = models.map((model) => model.toEntity()).toList();
      logger?.info('Success in getTagsByNames, fetched ${tags.length} tags');
      return Either.right(tags);
    });
  }

  /// Adds a new tag to the database.
  @override
  Future<Either<Failure, TagProjection>> addTag({required Tag tag}) async {
    logger?.info('Entering addTag with tag: ${tag.name}');
    // Check for duplicate
    final existingResult = await getByName(name: tag.name);
    if (existingResult.isRight()) {
      return Either.left(
        ValidationFailure('A tag with the slug "${tag.slug}" already exists.'),
      );
    }
    final handle = TagHandle.fromName(tag.name);
    final model = TagModel.fromEntity(tag);
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for addTag');
      final db = (txn as SembastTransaction).db;
      final saveResult = await _tagDatasource.saveTag(model, db: db);
      if (saveResult.isLeft()) {
        throw saveResult.getLeft().getOrElse(
          () => DatabaseFailure('Save failed'),
        );
      }
      logger?.info('Transaction operation completed for addTag');
      return TagProjection(handle: handle, tag: tag);
    });
  }

  /// Updates an existing tag in the database.
  @override
  Future<Either<Failure, Unit>> updateTag({
    required TagHandle handle,
    required Tag tag,
  }) async {
    logger?.info(
      'Entering updateTag with handle: $handle and tag: ${tag.name}',
    );
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for updateTag');
      final db = (txn as SembastTransaction).db;
      final newId = tag.name;
      if (handle.toString() != newId) {
        logger?.info('Name changed, deleting old record');
        final deleteResult = await _tagDatasource.deleteTag(
          handle.toString(),
          db: db,
        );
        if (deleteResult.isLeft()) {
          throw deleteResult.getLeft().getOrElse(
            () => DatabaseFailure('Delete old record failed'),
          );
        }
      }
      final model = TagModel.fromEntity(tag);
      logger?.info('Saving updated tag ${tag.name}');
      final saveResult = await _tagDatasource.saveTag(model, db: db);
      if (saveResult.isLeft()) {
        throw saveResult.getLeft().getOrElse(
          () => DatabaseFailure('Save failed'),
        );
      }
      logger?.info('Transaction operation completed for updateTag');
      return unit;
    });
  }

  /// Deletes a tag from the database.
  @override
  Future<Either<Failure, Unit>> deleteTag({required TagHandle handle}) async {
    logger?.info('Entering deleteTag with handle: $handle');
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for deleteTag');
      final db = (txn as SembastTransaction).db;
      final deleteResult = await _tagDatasource.deleteTag(
        handle.toString(),
        db: db,
      );
      if (deleteResult.isLeft()) {
        throw deleteResult.getLeft().getOrElse(
          () => DatabaseFailure('Delete failed'),
        );
      }
      logger?.info('Transaction operation completed for deleteTag');
      return unit;
    });
  }

  /// Retrieves a tag by handle.
  @override
  Future<Either<Failure, Tag>> getByHandle({required TagHandle handle}) async {
    logger?.info('Entering getByHandle with handle: $handle');
    final result = await _tagDatasource.getTagById(handle.toString());
    return result.fold(
      (failure) {
        logger?.warning(
          'Failed to get tag by handle: $handle, Error: ${failure.message}',
        );
        return Either.left(failure);
      },
      (model) {
        logger?.info('Successfully retrieved tag by handle: $handle');
        if (model == null) {
          logger?.info('Tag with handle $handle not found');
          return Either.left(NotFoundFailure('Tag not found'));
        }
        final tag = model.toEntity();
        logger?.info('Output: ${tag.name}');
        return Either.right(tag);
      },
    );
  }
}
