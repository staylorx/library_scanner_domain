import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AuthorRepository {
  TaskEither<Failure, List<Author>> getAuthors();
  TaskEither<Failure, Author> getAuthorByName({required String name});
  TaskEither<Failure, List<Author>> getAuthorsByNames({
    required List<String> names,
  });
  TaskEither<Failure, Author> addAuthor({
    required Author author,
    Transaction? txn,
  });
  TaskEither<Failure, Unit> updateAuthor({
    required Author author,
    Transaction? txn,
  });
  TaskEither<Failure, Unit> deleteAuthor({
    required Author author,
    Transaction? txn,
  });
  TaskEither<Failure, Author> getAuthorById({required String id});
  TaskEither<Failure, Author> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  });
}
