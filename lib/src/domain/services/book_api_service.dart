import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class IBookApiService {
  Future<Either<Failure, BookModel?>> fetchBookByIsbn({required String isbn});
}
