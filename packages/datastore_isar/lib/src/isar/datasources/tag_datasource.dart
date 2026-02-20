import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/tag_model.dart';
import '../database/isar_database.dart';
import '../schemas/tag_schema.dart';

class TagDatasource {
  final IsarDatabase _isarDb;

  TagDatasource({required IsarDatabase isarDb}) : _isarDb = isarDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  TagModel _fromSchema(TagSchema schema) {
    final map = jsonDecode(schema.dataJson) as Map<String, dynamic>;
    return TagModel.fromMap(map: map);
  }

  TagSchema _toSchema(TagModel tag) {
    return TagSchema()
      ..stringId = tag.id
      ..name = tag.name
      ..bookIds = tag.bookIds
      ..dataJson = jsonEncode(tag.toMap());
  }

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all tags from the collection.
  TaskEither<Failure, List<TagModel>> getAllTags() => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final schemas = await db.tagSchemas.where().findAll();
      return schemas.map(_fromSchema).toList();
    },
    (error, _) => DatabaseFailure('Failed to get all tags: $error'),
  );

  /// Returns a tag matching [name], or `null` if not found.
  TaskEither<Failure, TagModel?> getTagByName(String name) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final schema = await db.tagSchemas.getByName(name);
          return schema != null ? _fromSchema(schema) : null;
        },
        (error, _) => DatabaseFailure('Failed to get tag by name: $error'),
      );

  /// Returns tags whose names are in [names].
  TaskEither<Failure, List<TagModel>> getTagsByNames(List<String> names) =>
      TaskEither.tryCatch(
        () async {
          final db = await _isarDb.isar;
          final all = await db.tagSchemas.where().findAll();
          return all
              .where((s) => names.contains(s.name))
              .map(_fromSchema)
              .toList();
        },
        (error, _) => DatabaseFailure('Failed to get tags by names: $error'),
      );

  /// Returns a tag by [id], or `null` if not found.
  TaskEither<Failure, TagModel?> getTagById(String id) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      final schema = await db.tagSchemas.getByStringId(id);
      return schema != null ? _fromSchema(schema) : null;
    },
    (error, _) => DatabaseFailure('Failed to get tag by id: $error'),
  );

  // ─── Write operations ──────────────────────────────────────────────────────

  /// Inserts or replaces [tag] in the collection.
  TaskEither<Failure, Unit> saveTag(TagModel tag) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.tagSchemas.put(_toSchema(tag));
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save tag: $error'),
  );

  /// Deletes the tag with [id] from the collection.
  TaskEither<Failure, Unit> deleteTag(String id) => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.tagSchemas.deleteByStringId(id);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete tag: $error'),
  );

  /// Deletes all tags from the collection.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(
    () async {
      final db = await _isarDb.isar;
      await db.tagSchemas.clear();
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete all tags: $error'),
  );

  // ─── Relationship helpers ──────────────────────────────────────────────────

  /// Associates [bookId] with each tag named in [tagNames].
  TaskEither<Failure, Unit> addBookToTags(
    String bookId,
    List<String> tagNames,
  ) =>
      TaskEither.traverseList(
        tagNames,
        (name) => _addBookToTag(bookId, name),
      ).map((_) => unit);

  /// Removes [bookId] from each tag named in [tagNames].
  TaskEither<Failure, Unit> removeBookFromTags(
    String bookId,
    List<String> tagNames,
  ) =>
      TaskEither.traverseList(
        tagNames,
        (name) => _removeBookFromTag(bookId, name),
      ).map((_) => unit);

  // ─── Private helpers ──────────────────────────────────────────────────────

  TaskEither<Failure, Unit> _addBookToTag(String bookId, String tagName) =>
      getTagByName(tagName).flatMap((tag) {
        if (tag == null) return TaskEither.right(unit);
        if (tag.bookIds.contains(bookId)) return TaskEither.right(unit);
        final updated = tag.copyWith(bookIds: [...tag.bookIds, bookId]);
        return saveTag(updated);
      });

  TaskEither<Failure, Unit> _removeBookFromTag(
    String bookId,
    String tagName,
  ) => getTagByName(tagName).flatMap((tag) {
    if (tag == null) return TaskEither.right(unit);
    final updated = tag.copyWith(
      bookIds: tag.bookIds.where((id) => id != bookId).toList(),
    );
    return saveTag(updated);
  });
}
