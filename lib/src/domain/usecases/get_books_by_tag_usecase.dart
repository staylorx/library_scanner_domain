import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

class GetBooksByTagUseCase with Loggable {
  final BookRepository bookRepository;

  GetBooksByTagUseCase({required this.bookRepository});

  TaskEither<Failure, List<Book>> call({required Tag tag}) {
    return bookRepository.getBooksByTag(tag: tag);
  }
}
