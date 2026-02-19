import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:id_logging/id_logging.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for deleting a book from the repository.
class DeleteBookUsecase with Loggable {
  final BookRepository bookRepository;

  DeleteBookUsecase({Logger? logger, required this.bookRepository});

  /// Deletes a book by id and returns the updated list of books.
  /// Deletes a book by id and returns `unit` on success.
  TaskEither<Failure, Unit> call({required String id}) {
    logger?.info('DeleteBookUsecase: Entering call with id: $id');
    return bookRepository.getById(id: id).flatMap((book) {
      logger?.info(
        'DeleteBookUsecase: Deleting book: ${book.title} (businessIds: ${book.businessIds})',
      );
      return bookRepository.deleteById(item: book).map((_) {
        logger?.info('DeleteBookUsecase: Success in call');
        return unit;
      });
    });
  }
}
