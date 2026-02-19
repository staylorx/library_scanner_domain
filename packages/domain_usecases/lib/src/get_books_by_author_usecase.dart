import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:id_logging/id_logging.dart';

class GetBooksByAuthorUseCase with Loggable {
  final BookRepository bookRepository;

  GetBooksByAuthorUseCase({required this.bookRepository});

  TaskEither<Failure, List<Book>> call({required Author author}) {
    return bookRepository.getBooksByAuthor(author: author);
  }
}
