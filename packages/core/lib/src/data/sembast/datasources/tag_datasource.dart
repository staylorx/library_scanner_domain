import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/core/models/tag_model.dart';

class TagDatasource {
  final DatabaseService _dbService;

  /// Creates a datasource with required DatabaseService.
  TagDatasource({required DatabaseService dbService}) : _dbService = dbService;

  /// Retrieves all tags from the store.
  TaskEither<Failure, List<TagModel>> getAllTags() => _dbService
      .getAll(collection: 'tags')
      .map(
        (records) =>
            records.map((record) => TagModel.fromMap(map: record)).toList(),
      );

  /// Retrieves a tag by name.
  TaskEither<Failure, TagModel?> getTagByName(String name) => _dbService
      .query(collection: 'tags', filter: {'name': name})
      .map((records) {
        if (records.isEmpty) {
          return null;
        }
        return TagModel.fromMap(map: records.first);
      });

  /// Retrieves tags by a list of names.
  TaskEither<Failure, List<TagModel>> getTagsByNames(List<String> names) =>
      _dbService
          .query(
            collection: 'tags',
            filter: {
              'name': {'\$in': names},
            },
          )
          .map(
            (records) =>
                records.map((record) => TagModel.fromMap(map: record)).toList(),
          );

  /// Retrieves a tag by ID.
  TaskEither<Failure, TagModel?> getTagById(String id) =>
      _dbService.query(collection: 'tags', filter: {'id': id}).map((records) {
        if (records.isEmpty) {
          return null;
        }
        return TagModel.fromMap(map: records.first);
      });

  /// Saves a tag to the store.
  TaskEither<Failure, Unit> saveTag(TagModel tag, {Transaction? txn}) {
    final data = tag.toMap();
    final db = txn?.db;
    return _dbService
        .save(collection: 'tags', id: tag.id, data: data, db: db)
        .map((_) => unit);
  }

  /// Deletes a tag by ID.
  TaskEither<Failure, Unit> deleteTag(String id, {Transaction? txn}) {
    final db = txn?.db;
    return _dbService
        .delete(collection: 'tags', id: id, db: db)
        .map((_) => unit);
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
  ) => _dbService.transaction(operation: operation).map((_) => unit);
}
