import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class BookRepository {
  TaskEither<Failure, List<Book>> getBooks({int? limit, int? offset});
  TaskEither<Failure, Book> getBookByIdPair({required BookIdPair bookIdPair});
  TaskEither<Failure, Book> getBookByBusinessIds({required BookIdPairs bookId});
  TaskEither<Failure, Book> addBook({required Book book, Transaction? txn});
  TaskEither<Failure, Unit> updateBook({required Book book, Transaction? txn});
  TaskEither<Failure, Unit> deleteBook({required Book book, Transaction? txn});
  TaskEither<Failure, Book> getBookById({required String id});
  TaskEither<Failure, List<Book>> getBooksByAuthor({required Author author});
  TaskEither<Failure, List<Book>> getBooksByTag({required Tag tag});
}
