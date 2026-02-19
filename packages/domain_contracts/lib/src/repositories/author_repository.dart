import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'basic_crud_contract.dart';
import 'unit_of_work.dart';

abstract class AuthorRepository implements BasicCrudContract<Author> {
  @override
  TaskEither<Failure, List<Author>> getAll();

  TaskEither<Failure, Author> getAuthorByName({required String name});

  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  });

  @override
  TaskEither<Failure, Author> create({required Author item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Author> update({required Author item, UnitOfWork? txn});

  TaskEither<Failure, Author> updateAuthor({
    required Author author,
  });

  @override
  TaskEither<Failure, Unit> deleteById({
    required Author item,
    UnitOfWork? txn,
  });

  @override
  TaskEither<Failure, Author> getById({required String id});

  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  });

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork? txn});
}
