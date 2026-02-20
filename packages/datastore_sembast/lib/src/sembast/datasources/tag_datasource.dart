import 'package:datastore_sembast/src/models/tag_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'sembast_database.dart';

class TagDatasource {
  final SembastDatabase _sembastDb;

  TagDatasource({required SembastDatabase sembastDb})
      : _sembastDb = sembastDb;

  // ─── Read operations ────────────────────────────────────────────────────────

  /// Returns all tags from the store.
  TaskEither<Failure, List<TagModel>> getAllTags() => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final records = await _sembastDb.tagsStore.find(db);
      return records.map((r) => TagModel.fromMap(map: r.value)).toList();
    },
    (error, _) => DatabaseFailure('Failed to get all tags: $error'),
  );

  /// Returns a tag matching [name], or `null` if not found.
  ///
  /// Pass [txn] to read within an open Sembast transaction (ensures the read
  /// sees in-progress writes from the same transaction).
  TaskEither<Failure, TagModel?> getTagByName(
    String name, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      final finder = sembast.Finder(
        filter: sembast.Filter.equals('name', name),
      );
      final records = await _sembastDb.tagsStore.find(db, finder: finder);
      return records.isEmpty ? null : TagModel.fromMap(map: records.first.value);
    },
    (error, _) => DatabaseFailure('Failed to get tag by name: $error'),
  );

  /// Returns tags whose names are in [names].
  TaskEither<Failure, List<TagModel>> getTagsByNames(List<String> names) =>
      TaskEither.tryCatch(
        () async {
          final db = await _sembastDb.database;
          final finder = sembast.Finder(
            filter: sembast.Filter.inList('name', names),
          );
          final records = await _sembastDb.tagsStore.find(db, finder: finder);
          return records.map((r) => TagModel.fromMap(map: r.value)).toList();
        },
        (error, _) => DatabaseFailure('Failed to get tags by names: $error'),
      );

  /// Returns a tag by [id], or `null` if not found.
  TaskEither<Failure, TagModel?> getTagById(String id) => TaskEither.tryCatch(
    () async {
      final db = await _sembastDb.database;
      final record = await _sembastDb.tagsStore.record(id).get(db);
      return record != null ? TagModel.fromMap(map: record) : null;
    },
    (error, _) => DatabaseFailure('Failed to get tag by id: $error'),
  );

  // ─── Write operations ────────────────────────────────────────────────────────

  /// Inserts or replaces [tag] in the store.
  TaskEither<Failure, Unit> saveTag(
    TagModel tag, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.tagsStore.record(tag.id).put(db, tag.toMap());
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save tag: $error'),
  );

  /// Deletes the tag with [id] from the store.
  TaskEither<Failure, Unit> deleteTag(
    String id, {
    sembast.DatabaseClient? txn,
  }) => TaskEither.tryCatch(
    () async {
      final db = txn ?? await _sembastDb.database;
      await _sembastDb.tagsStore.record(id).delete(db);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete tag: $error'),
  );

  /// Deletes all tags from the store.
  TaskEither<Failure, Unit> deleteAll({sembast.DatabaseClient? txn}) =>
      TaskEither.tryCatch(
        () async {
          final db = txn ?? await _sembastDb.database;
          await _sembastDb.tagsStore.delete(db);
          return unit;
        },
        (error, _) => DatabaseFailure('Failed to delete all tags: $error'),
      );

  // ─── Relationship helpers ─────────────────────────────────────────────────

  /// Associates [bookId] with each tag named in [tagNames].
  ///
  /// Tags not found in the store are silently skipped. All reads and writes
  /// use [txn] so they are consistent within an open transaction.
  TaskEither<Failure, Unit> addBookToTags(
    String bookId,
    List<String> tagNames, {
    sembast.DatabaseClient? txn,
  }) =>
      TaskEither.traverseList(
        tagNames,
        (name) => _addBookToTag(bookId, name, txn),
      ).map((_) => unit);

  /// Removes [bookId] from each tag named in [tagNames].
  TaskEither<Failure, Unit> removeBookFromTags(
    String bookId,
    List<String> tagNames, {
    sembast.DatabaseClient? txn,
  }) =>
      TaskEither.traverseList(
        tagNames,
        (name) => _removeBookFromTag(bookId, name, txn),
      ).map((_) => unit);

  // ─── Private helpers ──────────────────────────────────────────────────────

  TaskEither<Failure, Unit> _addBookToTag(
    String bookId,
    String tagName,
    sembast.DatabaseClient? txn,
  ) =>
      // Pass txn so the read sees writes made earlier in the same transaction.
      getTagByName(tagName, txn: txn).flatMap((tag) {
        if (tag == null) return TaskEither.right(unit);
        if (tag.bookIds.contains(bookId)) return TaskEither.right(unit);
        final updated = tag.copyWith(
          bookIds: [...tag.bookIds, bookId],
        );
        return saveTag(updated, txn: txn);
      });

  TaskEither<Failure, Unit> _removeBookFromTag(
    String bookId,
    String tagName,
    sembast.DatabaseClient? txn,
  ) =>
      getTagByName(tagName, txn: txn).flatMap((tag) {
        if (tag == null) return TaskEither.right(unit);
        final updated = tag.copyWith(
          bookIds: tag.bookIds.where((id) => id != bookId).toList(),
        );
        return saveTag(updated, txn: txn);
      });
}
