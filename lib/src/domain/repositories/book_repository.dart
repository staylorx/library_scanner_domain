import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'basic_crud_contract.dart';

abstract class BookRepository implements BasicCrudContract<Book> {
  @override
  TaskEither<Failure, List<Book>> getAll();

  TaskEither<Failure, List<Book>> getBooks({int? limit, int? offset});

  TaskEither<Failure, List<Book>> listSection({int? limit, int? offset});

  TaskEither<Failure, Book> getBookByIdPair({required BookIdPair bookIdPair});

  TaskEither<Failure, Book> getBookByBusinessIds({required BookIdPairs bookId});

  @override
  TaskEither<Failure, Book> create({required Book item, Transaction? txn});

  @override
  TaskEither<Failure, Book> update({required Book item, Transaction? txn});

  @override
  TaskEither<Failure, Unit> deleteById({required Book item, Transaction? txn});

  @override
  TaskEither<Failure, Book> getById({required String id});

  TaskEither<Failure, List<Book>> getBooksByAuthor({required Author author});

  TaskEither<Failure, List<Book>> getBooksByTag({required Tag tag});

  @override
  TaskEither<Failure, Unit> deleteAll({Transaction? txn});
}
