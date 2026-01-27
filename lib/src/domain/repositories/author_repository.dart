import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'basic_crud_contract.dart';

abstract class AuthorRepository implements BasicCrudContract<Author> {
  @override
  TaskEither<Failure, List<Author>> getAll();

  TaskEither<Failure, Author> getAuthorByName({required String name});

  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  });

  @override
  TaskEither<Failure, Author> create({required Author item, Transaction? txn});

  @override
  TaskEither<Failure, Author> update({required Author item, Transaction? txn});

  TaskEither<Failure, Author> updateAuthor({
    required Author author,
    Transaction? txn,
  });

  @override
  TaskEither<Failure, Unit> deleteById({
    required Author item,
    Transaction? txn,
  });

  @override
  TaskEither<Failure, Author> getById({required String id});

  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  });

  @override
  TaskEither<Failure, Unit> deleteAll({Transaction? txn});
}
