import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

class GetBooksByTagUseCase with Loggable {
  final BookRepository _bookRepository;

  GetBooksByTagUseCase({required BookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Tag tag}) async {
    return await _bookRepository.getBooksByTag(tag: tag);
  }
}
