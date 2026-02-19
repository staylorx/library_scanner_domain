import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/core/models/book_model.dart';

class BookDatasource {
  final DatabaseService _dbService;

  /// Creates a datasource with required DatabaseService.
  BookDatasource({required DatabaseService dbService}) : _dbService = dbService;

  /// Retrieves all books from the store.
  TaskEither<Failure, List<BookModel>> getAllBooks() {
    return _dbService.getAll(collection: 'books').map((records) {
      return records.map((record) => BookModel.fromMap(map: record)).toList();
    });
  }

  /// Retrieves a book by ID.
  TaskEither<Failure, BookModel?> getBookById(String id) {
    return _dbService.query(collection: 'books', filter: {'id': id}).map((
      records,
    ) {
      if (records.isEmpty) {
        return null;
      }
      return BookModel.fromMap(map: records.first);
    });
  }

  /// Retrieves books containing a specific business ID pair.
  TaskEither<Failure, List<BookModel>> getBooksByBusinessIdPair(
    BookIdPair pair,
  ) {
    return _dbService
        .query(
          collection: 'books',
          filter: {
            '\$custom': (record) {
              final businessIdsRaw =
                  record.value['businessIds'] as List<dynamic>? ?? [];
              final businessIds = businessIdsRaw.map((e) {
                final idTypeString = e['idType'] as String;
                final idType = BookIdType.values.byName(idTypeString);
                return BookIdPair(
                  idType: idType,
                  idCode: e['idCode'] as String,
                );
              }).toList();
              return businessIds.any((p) => p == pair);
            },
          },
        )
        .map((records) {
          return records
              .map((record) => BookModel.fromMap(map: record))
              .toList();
        });
  }

  /// Retrieves books by author ID.
  TaskEither<Failure, List<BookModel>> getBooksByAuthorId(
    String authorId,
  ) => _dbService
      .query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final authorIds =
                (record['authorIds'] as List<dynamic>?)?.cast<String>() ?? [];
            return authorIds.contains(authorId);
          },
        },
      )
      .map(
        (records) =>
            records.map((record) => BookModel.fromMap(map: record)).toList(),
      );

  /// Retrieves books by tag ID.
  TaskEither<Failure, List<BookModel>> getBooksByTagId(String tagId) =>
      _dbService
          .query(
            collection: 'books',
            filter: {
              '\$custom': (record) {
                final tagIds =
                    (record['tagIds'] as List<dynamic>?)?.cast<String>() ?? [];
                return tagIds.contains(tagId);
              },
            },
          )
          .map(
            (records) => records
                .map((record) => BookModel.fromMap(map: record))
                .toList(),
          );

  /// Retrieves a book by exact business IDs.
  TaskEither<Failure, BookModel?> getBookByBusinessIds(
    List<BookIdPair> businessIds,
  ) => _dbService
      .query(
        collection: 'books',
        filter: {
          '\$custom': (record) {
            final businessIdsRaw =
                record.value['businessIds'] as List<dynamic>? ?? [];
            final recordBusinessIds = businessIdsRaw.map((e) {
              final idTypeString = e['idType'] as String;
              final idType = BookIdType.values.byName(idTypeString);
              return BookIdPair(idType: idType, idCode: e['idCode'] as String);
            }).toList();
            return BookIdPairs(pairs: recordBusinessIds) ==
                BookIdPairs(pairs: businessIds);
          },
        },
      )
      .map((records) {
        if (records.isEmpty) {
          return null;
        }
        return BookModel.fromMap(map: records.first);
      });

  /// Saves a book to the store.
  TaskEither<Failure, Unit> saveBook(BookModel book, {Transaction? txn}) {
    final data = book.toMap();
    final db = txn?.db;
    return _dbService
        .save(collection: 'books', id: book.id, data: data, db: db)
        .map((_) => unit);
  }

  /// Deletes a book by ID.
  TaskEither<Failure, Unit> deleteBook(String id, {Transaction? txn}) {
    final db = txn?.db;
    return _dbService
        .delete(collection: 'books', id: id, db: db)
        .map((_) => unit);
  }

  /// Removes author from books.
  TaskEither<Failure, Unit> removeAuthorFromBooks(
    String name, {
    Transaction? txn,
  }) {
    final db = txn?.db;
    return _dbService
        .getAll(collection: 'books', db: db)
        .flatMap(
          (records) => TaskEither.traverseList(records, (record) {
            final model = BookModel.fromMap(map: record);
            if (model.authorIds.contains(name)) {
              final updatedAuthorIds = List<String>.from(model.authorIds)
                ..remove(name);
              final updatedModel = BookModel(
                id: model.id,
                businessIds: model.businessIds,
                title: model.title,
                description: model.description,
                authorIds: updatedAuthorIds,
                tagIds: model.tagIds,
                publishedDate: model.publishedDate,
              );
              return saveBook(updatedModel, txn: txn);
            }
            return TaskEither<Failure, Unit>.right(unit);
          }).map((_) => unit),
        );
  }

  /// Executes a transaction with the given operation.
  TaskEither<Failure, Unit> transaction(
    Future<Unit> Function(dynamic txn) operation,
  ) {
    return _dbService.transaction(operation: operation);
  }
}
