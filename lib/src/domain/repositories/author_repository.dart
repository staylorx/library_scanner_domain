import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../entities/author.dart';
import 'unit_of_work.dart';

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
}
