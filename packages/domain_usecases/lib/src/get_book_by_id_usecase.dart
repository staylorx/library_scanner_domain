import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving a book by ID.
class GetBookByIdUsecase with Loggable {
  final BookRepository bookRepository;

  GetBookByIdUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves a book by ID.
  TaskEither<Failure, Book> call({required String id}) {
    logger?.info('GetBookByIdUsecase: Entering call with id: $id');
    return bookRepository.getById(id: id).map((book) {
      logger?.info(
        'GetBookByIdUsecase: Output: ${book.title} (id: ${book.id})',
      );
      return book;
    });
  }
}
