import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

class GetBooksByTagUseCase {
  final AbstractBookRepository _bookRepository;

  GetBooksByTagUseCase({required AbstractBookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Tag tag}) async {
    return await _bookRepository.getBooksByTag(tag: tag);
  }
}
