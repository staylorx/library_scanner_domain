import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import '../../models/tag_model.dart';
import '../database/hive_database.dart';

class TagDatasource {
  final HiveDatabase _hiveDb;

  TagDatasource({required HiveDatabase hiveDb}) : _hiveDb = hiveDb;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _cast(dynamic raw) =>
      (raw as Map).cast<String, dynamic>();

  // ─── Read operations ──────────────────────────────────────────────────────

  /// Returns all tags from the box.
  TaskEither<Failure, List<TagModel>> getAllTags() => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.tagsBox;
      return box.values
          .map((v) => TagModel.fromMap(map: _cast(v)))
          .toList();
    },
    (error, _) => DatabaseFailure('Failed to get all tags: $error'),
  );

  /// Returns a tag matching [name], or `null` if not found.
  TaskEither<Failure, TagModel?> getTagByName(String name) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.tagsBox;
          final match = box.values.cast<dynamic>().firstWhere(
            (v) => (_cast(v)['name'] as String?) == name,
            orElse: () => null,
          );
          return match != null ? TagModel.fromMap(map: _cast(match)) : null;
        },
        (error, _) => DatabaseFailure('Failed to get tag by name: $error'),
      );

  /// Returns tags whose names are in [names].
  TaskEither<Failure, List<TagModel>> getTagsByNames(List<String> names) =>
      TaskEither.tryCatch(
        () async {
          final box = await _hiveDb.tagsBox;
          return box.values
              .where((v) => names.contains((_cast(v))['name'] as String?))
              .map((v) => TagModel.fromMap(map: _cast(v)))
              .toList();
        },
        (error, _) => DatabaseFailure('Failed to get tags by names: $error'),
      );

  /// Returns a tag by [id], or `null` if not found.
  TaskEither<Failure, TagModel?> getTagById(String id) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.tagsBox;
      final raw = box.get(id);
      return raw != null ? TagModel.fromMap(map: _cast(raw)) : null;
    },
    (error, _) => DatabaseFailure('Failed to get tag by id: $error'),
  );

  // ─── Write operations ──────────────────────────────────────────────────────

  /// Inserts or replaces [tag] in the box.
  TaskEither<Failure, Unit> saveTag(TagModel tag) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.tagsBox;
      await box.put(tag.id, tag.toMap());
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to save tag: $error'),
  );

  /// Deletes the tag with [id] from the box.
  TaskEither<Failure, Unit> deleteTag(String id) => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.tagsBox;
      await box.delete(id);
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete tag: $error'),
  );

  /// Deletes all tags from the box.
  TaskEither<Failure, Unit> deleteAll() => TaskEither.tryCatch(
    () async {
      final box = await _hiveDb.tagsBox;
      await box.clear();
      return unit;
    },
    (error, _) => DatabaseFailure('Failed to delete all tags: $error'),
  );

  // ─── Relationship helpers ──────────────────────────────────────────────────

  /// Associates [bookId] with each tag named in [tagNames].
  ///
  /// Tags not found in the box are silently skipped.
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
