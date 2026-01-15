import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class GetBooksByAuthorUseCase {
  final BookRepository _bookRepository;

  GetBooksByAuthorUseCase({required BookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Author author}) async {
    return await _bookRepository.getBooksByAuthor(author: author);
  }
}
