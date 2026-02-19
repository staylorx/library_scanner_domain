import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving a book by BookIdPair.
class GetBookByIdPairUsecase with Loggable {
  final BookRepository bookRepository;

  GetBookByIdPairUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves a book by BookIdPair.
  TaskEither<Failure, Book> call({required BookIdPair bookIdPair}) {
    logger?.info(
      'getByIdPairpairUsecase: Entering call with bookIdPair: $bookIdPair',
    );
    return bookRepository.getBookByIdPair(bookIdPair: bookIdPair).map((book) {
      logger?.info(
        'getByIdPairpairUsecase: Output: ${book.title} (businessIds: ${book.businessIds})',
      );
      return book;
    });
  }
}
