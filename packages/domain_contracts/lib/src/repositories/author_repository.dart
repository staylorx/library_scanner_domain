import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'basic_crud_contract.dart';

abstract class AuthorRepository implements BasicCrudContract<Author> {
  TaskEither<Failure, Author> getAuthorByName({required String name});

  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  });

  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  });
}
