import 'package:fpdart/fpdart.dart';
import '../../utils/failure.dart';
import '../entities/author.dart';
import '../value_objects/author_handle.dart';

/// Projection class for author with handle
class AuthorProjection {
  final AuthorHandle handle;
  final Author author;

  const AuthorProjection({required this.handle, required this.author});
}

abstract class AbstractAuthorRepository {
  Future<Either<Failure, List<Author>>> getAuthors();
  Future<Either<Failure, Author?>> getAuthorByName({required String name});
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  });
  Future<Either<Failure, AuthorHandle>> addAuthor({required Author author});
  Future<Either<Failure, Unit>> updateAuthor({
    required AuthorHandle handle,
    required Author author,
  });
  Future<Either<Failure, Unit>> deleteAuthor({required AuthorHandle handle});
  Future<Either<Failure, Author?>> getAuthorByHandle({
    required AuthorHandle handle,
  });
}
