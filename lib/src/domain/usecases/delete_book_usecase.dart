import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for deleting a book from the repository.
class DeleteBookUsecase with Loggable {
  final BookRepository bookRepository;

  DeleteBookUsecase({Logger? logger, required this.bookRepository});

  /// Deletes a book by id and returns the updated list of books.
  TaskEither<Failure, List<Book>> call({required String id}) {
    logger?.info('DeleteBookUsecase: Entering call with id: $id');
    return bookRepository.getBookById(id: id).flatMap((book) {
      logger?.info(
        'DeleteBookUsecase: Deleting book: ${book.title} (businessIds: ${book.businessIds})',
      );
      return bookRepository.deleteBook(book: book).flatMap((_) {
        return bookRepository.getBooks().map((books) {
          final updatedBooks = books.where((b) => b.id != id).toList();
          logger?.info('DeleteBookUsecase: Success in call');
          logger?.info(
            'DeleteBookUsecase: Output: ${updatedBooks.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
          );
          return updatedBooks;
        });
      });
    });
  }
}
