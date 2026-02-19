import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:uuid/uuid.dart';

import '../sembast/datasources/tag_datasource.dart';
import '../models/tag_model.dart';
import '../sembast/unit_of_work/sembast_transaction_handle.dart';

/// Implementation of tag repository using Sembast.
class TagRepositoryImpl with Loggable implements TagRepository {
  final TagDatasource tagDatasource;
  final UnitOfWork<TransactionHandle> unitOfWork;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl({required this.tagDatasource, required this.unitOfWork});

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
    final UnitOfWork<TransactionHandle> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run(
      (UnitOfWork<TransactionHandle> t) => tagDatasource
          .saveTag(
            model,
            txn: (t.transactionHandle as SembastTransactionHandle?)?.dbClient,
          )
          .map((_) => tagWithId),
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
    final UnitOfWork<TransactionHandle> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run((UnitOfWork<TransactionHandle> t) {
      logger?.info('Transaction started for updateTag');
      final model = TagModel.fromEntity(tag);
      logger?.info('Saving updated tag ${tag.name}');
      return tagDatasource
          .saveTag(
            model,
            txn: (t.transactionHandle as SembastTransactionHandle?)?.dbClient,
          )
          .map((_) => tag);
    });
  }

  /// Deletes a tag from the database.
  @override
  TaskEither<Failure, Unit> deleteById({
    required Tag item,
    UnitOfWork<TransactionHandle>? txn,
  }) {
    final tag = item;
    logger?.info('Entering deleteTag with tag: ${tag.name}');
    final UnitOfWork<TransactionHandle> effectiveTxn = txn ?? unitOfWork;
    return effectiveTxn.run((UnitOfWork<TransactionHandle> t) {
      logger?.info('Transaction started for deleteTag');
      return tagDatasource
          .deleteTag(
            tag.id,
            txn: (t.transactionHandle as SembastTransactionHandle?)?.dbClient,
          )
          .map((_) => unit);
    });
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
