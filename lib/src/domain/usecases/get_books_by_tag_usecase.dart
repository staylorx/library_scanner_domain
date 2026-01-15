import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

class GetBooksByTagUseCase {
  final BookRepository _bookRepository;

  GetBooksByTagUseCase({required BookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Tag tag}) async {
    return await _bookRepository.getBooksByTag(tag: tag);
  }
}
