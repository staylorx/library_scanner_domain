import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../entities/author.dart';

abstract class IAuthorRepository {
  Future<Either<Failure, List<Author>>> getAuthors();
  Future<Either<Failure, Author?>> getAuthorByName({required String name});
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  });
  Future<Either<Failure, Unit>> addAuthor({required Author author});
  Future<Either<Failure, Unit>> updateAuthor({required Author author});
  // TODO: verify that we're removing the author from books when deleting
  Future<Either<Failure, Unit>> deleteAuthor({required Author author});
}
