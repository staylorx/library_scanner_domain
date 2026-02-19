import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';

import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';

import '../sembast/datasources/tag_datasource.dart';
import '../models/tag_model.dart';

import 'base_repository.dart';

/// Implementation of tag repository using Sembast.
class TagRepositoryImpl extends SembastBaseRepository with Loggable implements TagRepository {
  final TagDatasource tagDatasource;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl({required this.tagDatasource, required UnitOfWork<TransactionHandle> unitOfWork})
      : super(unitOfWork);

  /// Retrieves all tags from the database.
  @override
  TaskEither<Failure, List<Tag>> getAll() {
    logger?.info('Entering list');
    return tagDatasource.getAllTags().map((models) {
      logger?.info('Successfully retrieved ${models.length} tags');
      final tags = models.map((model) => model.toEntity()).toList();
      return tags;
    });
  }

  /// Retrieves a tag by name.
  @override
  TaskEither<Failure, Tag> getByName({required String name}) {
    logger?.info('Entering getByName with name: $name');
    return tagDatasource.getTagByName(name).flatMap((model) {
      if (model == null) {
        logger?.info('Tag with name $name not found');
        return TaskEither.left(NotFoundFailure('Tag not found'));
      }
      logger?.info('Success, fetched tag ${model.name}');
      return TaskEither.right(model.toEntity());
    });
  }

  /// Retrieves tags by a list of names.
  @override
  TaskEither<Failure, List<Tag>> getTagsByNames({required List<String> names}) {
    logger?.info('Entering getTagsByNames with names: $names');
    if (names.isEmpty) {
      logger?.info('names is empty, returning empty list');
      return TaskEither.right([]);
    }
    return tagDatasource.getTagsByNames(names).map((models) {
      final tags = models.map((model) => model.toEntity()).toList();
      logger?.info('Success in getTagsByNames, fetched ${tags.length} tags');
      return tags;
    });
  }

  /// Creates a new tag in the database.
  @override
  TaskEither<Failure, Tag> create({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final tag = item;
    logger?.info('Entering createTag with tag: ${tag.name}, id: ${tag.id}');
    final tagWithId = tag.id.isNotEmpty
        ? tag
        : tag.copyWith(id: const Uuid().v4());
    final model = TagModel.fromEntity(tagWithId);
    logger?.info('Transaction started for createTag');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => tagDatasource.saveTag(model, txn: dbClient).map((_) => tagWithId),
    );
  }

  /// Updates an existing tag in the database.
  @override
  TaskEither<Failure, Tag> update({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final tag = item;
    logger?.info('Entering updateTag with tag: ${tag.name}');
    logger?.info('Transaction started for updateTag');
    final model = TagModel.fromEntity(tag);
    logger?.info('Saving updated tag ${tag.name}');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => tagDatasource.saveTag(model, txn: dbClient).map((_) => tag),
    );
  }

  /// Deletes a tag from the database.
  @override
  TaskEither<Failure, Unit> deleteById({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final tag = item;
    logger?.info('Entering deleteTag with tag: ${tag.name}');
    return runInTransaction(
      txn: txn,
      operation: (dbClient) => tagDatasource
          .deleteTag(tag.id, txn: dbClient)
          .map((_) => unit),
    );
  }

  /// Retrieves a tag by handle.
  @override
  TaskEither<Failure, Tag> getById({required String id}) {
    logger?.info('Entering getById with id: $id');
    return tagDatasource.getTagById(id).flatMap((model) {
      logger?.info('Successfully retrieved tag by id: $id');
      if (model == null) {
        logger?.info('Tag with id $id not found');
        return TaskEither.left(NotFoundFailure('Tag not found'));
      }
      final tag = model.toEntity();
      logger?.info('Output: ${tag.name}');
      return TaskEither.right(tag);
    });
  }

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn}) {
    throw UnimplementedError();
  }
}
