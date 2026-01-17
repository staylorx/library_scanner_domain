import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../entities/author.dart';

abstract class AuthorRepository {
  Future<Either<Failure, List<Author>>> getAuthors();
  Future<Either<Failure, Author>> getByName({required String name});
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  });
  Future<Either<Failure, Author>> addAuthor({required Author author});
  Future<Either<Failure, Unit>> updateAuthor({required Author author});
  Future<Either<Failure, Unit>> deleteAuthor({required Author author});
  Future<Either<Failure, Author>> getById({required String id});
}
