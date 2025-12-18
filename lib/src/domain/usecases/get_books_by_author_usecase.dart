import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class GetBooksByAuthorUseCase {
  final AbstractBookRepository _bookRepository;

  GetBooksByAuthorUseCase({required AbstractBookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Author author}) async {
    return await _bookRepository.getBooksByAuthor(author: author);
  }
}
