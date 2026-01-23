import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AuthorRepository {
  Future<Either<Failure, List<Author>>> getAuthors();
  Future<Either<Failure, Author>> getAuthorByName({required String name});
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  });
  Future<Either<Failure, Author>> addAuthor({
    required Author author,
    Transaction? txn,
  });
  Future<Either<Failure, Unit>> updateAuthor({
    required Author author,
    Transaction? txn,
  });
  Future<Either<Failure, Unit>> deleteAuthor({
    required Author author,
    Transaction? txn,
  });
  Future<Either<Failure, Author>> getAuthorById({required String id});
  Future<Either<Failure, Author>> getAuthorByIdPair({
    required AuthorIdPair authorIdPair,
  });
}
