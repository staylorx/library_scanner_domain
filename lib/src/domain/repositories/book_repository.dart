import 'package:fpdart/fpdart.dart';
import '../entities/book.dart';
import '../entities/author.dart';
import '../entities/tag.dart';
import '../../utils/failure.dart';
import '../value_objects/book_id.dart';

abstract class IBookRepository {
  Future<Either<Failure, List<Book>>> getBooks({int? limit, int? offset});
  Future<Either<Failure, Book?>> getBookByIdPairPair({
    required BookIdPair bookIdPair,
  });
  Future<Either<Failure, Unit>> addBook({required Book book});
  Future<Either<Failure, Unit>> updateBook({required Book book});
  Future<Either<Failure, Unit>> deleteBook({required Book book});
  Future<Either<Failure, List<Book>>> getBooksByAuthor({
    required Author author,
  });
  Future<Either<Failure, List<Book>>> getBooksByTag({required Tag tag});
}
