import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/core/models/author_model.dart';
import 'package:library_scanner_domain/src/data/core/models/book_model.dart';
import 'package:library_scanner_domain/src/data/core/models/tag_model.dart';
import 'author_datasource.dart';
import 'book_datasource.dart';
import 'tag_datasource.dart';

class LibraryDatasource {
  final DatabaseService _dbService;
  final AuthorDatasource _authorDatasource;
  final BookDatasource _bookDatasource;
  final TagDatasource _tagDatasource;

  /// Creates a datasource with required dependencies.
  LibraryDatasource({
    required DatabaseService dbService,
    required AuthorDatasource authorDatasource,
    required BookDatasource bookDatasource,
    required TagDatasource tagDatasource,
  }) : _dbService = dbService,
       _authorDatasource = authorDatasource,
       _bookDatasource = bookDatasource,
       _tagDatasource = tagDatasource;

  /// Clears all data from the library.
  Future<Either<Failure, Unit>> clearAll() async {
    final result = await _dbService.clearAll();
    return result.map((_) => unit);
  }

  /// Imports authors, tags, and books in a transaction.
  Future<Either<Failure, Unit>> importEntities({
    required List<Author> authors,
    required List<Tag> tags,
    required List<Book> books,
  }) async {
    final result = await _dbService.transaction(
      operation: (txn) async {
        // Save authors
        for (final author in authors) {
          final authorModel = AuthorModel.fromEntity(author, author.name);
          final saveResult = await _authorDatasource.saveAuthor(
            authorModel,
            db: txn,
          );
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save author failed'),
            );
          }
        }

        // Save tags
        for (final tag in tags) {
          final tagModel = TagModel.fromEntity(tag);
          final saveResult = await _tagDatasource.saveTag(tagModel, db: txn);
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save tag failed'),
            );
          }
        }

        // Save books
        for (final book in books) {
          final bookKey = BookHandle.generate();
          final bookModel = BookModel.fromEntity(book, bookKey.toString());
          final saveResult = await _bookDatasource.saveBook(bookModel, db: txn);
          if (saveResult.isLeft()) {
            throw saveResult.getLeft().getOrElse(
              () => DatabaseFailure('Save book failed'),
            );
          }
        }
      },
    );
    return result.map((_) => unit);
  }
}
