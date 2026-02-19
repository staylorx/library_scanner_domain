import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'basic_crud_contract.dart';

abstract class BookRepository implements BasicCrudContract<Book> {
  @override
  TaskEither<Failure, List<Book>> getAll();

  TaskEither<Failure, List<Book>> getBooks({int? limit, int? offset});

  TaskEither<Failure, List<Book>> listSection({int? limit, int? offset});

  TaskEither<Failure, Book> getBookByIdPair({required BookIdPair bookIdPair});

  TaskEither<Failure, Book> getBookByBusinessIds({required BookIdPairs bookId});

  TaskEither<Failure, List<Book>> getBooksByAuthor({required Author author});

  TaskEither<Failure, List<Book>> getBooksByTag({required Tag tag});

  @override
  TaskEither<Failure, Book> create({required Book item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Book> update({required Book item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Unit> deleteById({required Book item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork? txn});
}
