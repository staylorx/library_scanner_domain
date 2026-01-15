import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/core/models/tag_model.dart';

class TagDatasource {
  final DatabaseService _dbService;

  /// Creates a datasource with required DatabaseService.
  TagDatasource({required DatabaseService dbService}) : _dbService = dbService;

  /// Retrieves all tags from the store.
  Future<Either<Failure, List<TagModel>>> getAllTags() async {
    try {
      final result = await _dbService.getAll(collection: 'tags');
      return result.match(
        (failure) => Either.left(failure),
        (records) => Either.right(
          records.map((record) => TagModel.fromMap(map: record)).toList(),
        ),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get all tags: $e'));
    }
  }

  /// Retrieves a tag by name.
  Future<Either<Failure, TagModel?>> getTagByName(String name) async {
    try {
      final result = await _dbService.query(
        collection: 'tags',
        filter: {'name': name},
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(TagModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get tag by name: $e'));
    }
  }

  /// Retrieves tags by a list of names.
  Future<Either<Failure, List<TagModel>>> getTagsByNames(
    List<String> names,
  ) async {
    try {
      final result = await _dbService.query(
        collection: 'tags',
        filter: {
          'name': {'\$in': names},
        },
      );
      return result.match(
        (failure) => Either.left(failure),
        (records) => Either.right(
          records.map((record) => TagModel.fromMap(map: record)).toList(),
        ),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get tags by names: $e'));
    }
  }

  /// Retrieves a tag by ID.
  Future<Either<Failure, TagModel?>> getTagById(String id) async {
    try {
      final result = await _dbService.query(
        collection: 'tags',
        filter: {'id': id},
      );
      return result.match((failure) => Either.left(failure), (records) {
        if (records.isEmpty) {
          return Either.right(null);
        }
        return Either.right(TagModel.fromMap(map: records.first));
      });
    } catch (e) {
      return Either.left(ServiceFailure('Failed to get tag by ID: $e'));
    }
  }

  /// Saves a tag to the store.
  Future<Either<Failure, Unit>> saveTag(TagModel tag, {dynamic db}) async {
    try {
      final data = tag.toMap();
      final result = await _dbService.save(
        collection: 'tags',
        id: tag.id,
        data: data,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to save tag: $e'));
    }
  }

  /// Deletes a tag by ID.
  Future<Either<Failure, Unit>> deleteTag(String id, {dynamic db}) async {
    try {
      final result = await _dbService.delete(
        collection: 'tags',
        id: id,
        db: db,
      );
      return result.match(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } catch (e) {
      return Either.left(ServiceFailure('Failed to delete tag: $e'));
    }
  }

  /// Adds book to tags.
  Future<Either<Failure, Unit>> addBookToTags(
    String bookId,
    List<String> tagNames, {
    dynamic db,
  }) async {
    try {
      for (final tagName in tagNames) {
        final tagResult = await getTagByName(tagName);
        if (tagResult.isRight()) {
          final tag = tagResult.getRight().getOrElse(() => null);
          if (tag != null) {
            final updatedBookIds = List<String>.from(tag.bookIdPairs);
            if (!updatedBookIds.contains(bookId)) {
              updatedBookIds.add(bookId);
            }
            final updatedTag = TagModel(
              id: tag.id,
              name: tag.name,
              description: tag.description,
              color: tag.color,
              slug: tag.slug,
              bookIdPairs: updatedBookIds,
            );
            final saveResult = await saveTag(updatedTag, db: db);
            if (saveResult.isLeft()) {
              return saveResult;
            }
          }
        }
      }
      return Either.right(unit);
    } catch (e) {
      return Either.left(ServiceFailure('Failed to add book to tags: $e'));
    }
  }

  /// Removes book from tags.
  Future<Either<Failure, Unit>> removeBookFromTags(
    String bookId,
    List<String> tagNames, {
    dynamic db,
  }) async {
    try {
      for (final tagName in tagNames) {
        final tagResult = await getTagByName(tagName);
        if (tagResult.isRight()) {
          final tag = tagResult.getRight().getOrElse(() => null);
          if (tag != null) {
            final updatedBookIds = List<String>.from(tag.bookIdPairs)
              ..remove(bookId);
            final updatedTag = TagModel(
              id: tag.id,
              name: tag.name,
              description: tag.description,
              color: tag.color,
              slug: tag.slug,
              bookIdPairs: updatedBookIds,
            );
            final saveResult = await saveTag(updatedTag, db: db);
            if (saveResult.isLeft()) {
              return saveResult;
            }
          }
        }
      }
      return Either.right(unit);
    } catch (e) {
      return Either.left(ServiceFailure('Failed to remove book from tags: $e'));
    }
  }

  /// Executes a transaction with the given operation.
  Future<Either<Failure, Unit>> transaction(
    Future<void> Function(dynamic txn) operation,
  ) async {
    final result = await _dbService.transaction(operation: operation);
    return result.map((_) => unit);
  }
}
