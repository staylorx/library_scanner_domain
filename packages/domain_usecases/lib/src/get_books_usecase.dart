import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving all books from the repository.
class GetBooksUsecase with Loggable {
  final BookRepository bookRepository;

  GetBooksUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves all books from the repository.
  TaskEither<Failure, List<Book>> call() {
    logger?.info('GetBooksUsecase: Entering call');
    return bookRepository.getBooks().map((books) {
      logger?.info(
        'GetBooksUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
      );
      return books;
    });
  }
}
