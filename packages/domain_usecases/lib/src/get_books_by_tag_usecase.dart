import 'package:fpdart/fpdart.dart';

import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:id_logging/id_logging.dart';

class GetBooksByTagUseCase with Loggable {
  final BookRepository bookRepository;

  GetBooksByTagUseCase({required this.bookRepository});

  TaskEither<Failure, List<Book>> call({required Tag tag}) {
    return bookRepository.getBooksByTag(tag: tag);
  }
}
