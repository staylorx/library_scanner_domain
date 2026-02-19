import 'package:datastore_sembast/src/models/tag_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;

import 'sembast_database.dart';
import '../unit_of_work/sembast_transaction.dart';

class TagDatasource {
  final SembastDatabase _sembastDb;

  /// Creates a datasource with required SembastDatabase.
  TagDatasource({required SembastDatabase sembastDb}) : _sembastDb = sembastDb;

  /// Retrieves all tags from the store.
  TaskEither<Failure, List<TagModel>> getAllTags() => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final records = await _sembastDb.tagsStore.find(db);
      return records.map((r) => TagModel.fromMap(map: r.value)).toList();
    },
    (error, stackTrace) => DatabaseFailure('Failed to get all tags: $error'),
  );

  /// Retrieves a tag by name.
  TaskEither<Failure, TagModel?> getTagByName(String name) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final finder = sembast.Finder(
            filter: sembast.Filter.equals('name', name),
          );
          final records = await _sembastDb.tagsStore.find(db, finder: finder);
          if (records.isEmpty) {
            return null;
          }
          return TagModel.fromMap(map: records.first.value);
        },
        (error, stackTrace) =>
            DatabaseFailure('Failed to get tag by name: $error'),
      );

  /// Retrieves tags by a list of names.
  TaskEither<Failure, List<TagModel>> getTagsByNames(List<String> names) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final namesList = names.toList();
          final finder = sembast.Finder(
            filter: sembast.Filter.inList('name', namesList),
          );
          final records = await _sembastDb.tagsStore.find(db, finder: finder);
          return records.map((r) => TagModel.fromMap(map: r.value)).toList();
        },
        (error, stackTrace) =>
            DatabaseFailure('Failed to get tags by names: $error'),
      );

  /// Retrieves a tag by ID.
  TaskEither<Failure, TagModel?> getTagById(String id) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final record = await _sembastDb.tagsStore.record(id).get(db);
          return record != null ? TagModel.fromMap(map: record) : null;
        },
        (error, stackTrace) => DatabaseFailure('Failed to get tag by id: $error'),
      );

  /// Saves a tag to the store.
  TaskEither<Failure, Unit> saveTag(TagModel tag, {Transaction? txn}) {
    return TaskEither.tryCatch(() async {
      final data = tag.toMap();
      final db = txn?.db as sembast.Database? ?? await _sembastDb.database;
      await _sembastDb.tagsStore.record(tag.id).put(db, data);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to save tag: $error'));
  }

  /// Deletes a tag by ID.
  TaskEither<Failure, Unit> deleteTag(String id, {Transaction? txn}) {
    return TaskEither.tryCatch(() async {
      final db = txn?.db as sembast.Database? ?? await _sembastDb.database;
      await _sembastDb.tagsStore.record(id).delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to delete tag: $error'));
  }

  /// Adds book to tags.
  TaskEither<Failure, Unit> addBookToTags(
    String bookId,
    List<String> tagNames, {
    Transaction? txn,
  }) => TaskEither.traverseList(
    tagNames,
    (tagName) => _addBookToTag(bookId, tagName, txn),
  ).map((_) => unit);

  TaskEither<Failure, Unit> _addBookToTag(
    String bookId,
    String tagName,
    Transaction? txn,
  ) => getTagByName(tagName).flatMap((tag) {
    if (tag == null) return TaskEither.right(unit);
    final updatedBookIds = List<String>.from(tag.bookIds);
    if (!updatedBookIds.contains(bookId)) {
      updatedBookIds.add(bookId);
    }
    final updatedTag = TagModel(
      id: tag.id,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      slug: tag.slug,
      bookIds: updatedBookIds,
    );
    return saveTag(updatedTag, txn: txn);
  });

  /// Removes book from tags.
  TaskEither<Failure, Unit> removeBookFromTags(
    String bookId,
    List<String> tagNames, {
    Transaction? txn,
  }) => TaskEither.traverseList(
    tagNames,
    (tagName) => _removeBookFromTag(bookId, tagName, txn),
  ).map((_) => unit);

  TaskEither<Failure, Unit> _removeBookFromTag(
    String bookId,
    String tagName,
    Transaction? txn,
  ) => getTagByName(tagName).flatMap((tag) {
    if (tag == null) return TaskEither.right(unit);
    final updatedBookIds = List<String>.from(tag.bookIds)..remove(bookId);
    final updatedTag = TagModel(
      id: tag.id,
      name: tag.name,
      description: tag.description,
      color: tag.color,
      slug: tag.slug,
      bookIds: updatedBookIds,
    );
    return saveTag(updatedTag, txn: txn);
  });

  /// Executes a transaction with the given operation.
  TaskEither<Failure, Unit> transaction(
    Future<Unit> Function(dynamic txn) operation,
  ) => TaskEither.tryCatch(() async {
    final db = await _sembastDb.database;
    await db.transaction((txn) async {
      await operation(SembastTransaction(txn));
    });
    return unit;
  }, (error, stackTrace) => DatabaseFailure('Transaction failed: $error'));
}
