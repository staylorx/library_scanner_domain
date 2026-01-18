import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks({int? limit, int? offset});
  Future<Either<Failure, Book>> getBookByIdPair({
    required BookIdPair bookIdPair,
  });
  Future<Either<Failure, Book>> getBookByBusinessIds({
    required BookIdPairs bookId,
  });
  Future<Either<Failure, Book>> addBook({required Book book, Transaction? txn});
  Future<Either<Failure, Unit>> updateBook({
    required Book book,
    Transaction? txn,
  });
  Future<Either<Failure, Unit>> deleteBook({
    required Book book,
    Transaction? txn,
  });
  Future<Either<Failure, Book>> getBookById({required String id});
  Future<Either<Failure, List<Book>>> getBooksByAuthor({
    required Author author,
  });
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag});
}
