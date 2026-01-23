import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

class GetBooksByAuthorUseCase with Loggable {
  final BookRepository bookRepository;

  GetBooksByAuthorUseCase({required this.bookRepository});

  TaskEither<Failure, List<Book>> call({required Author author}) {
    return bookRepository.getBooksByAuthor(author: author);
  }
}
