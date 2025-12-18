import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for deleting a book from the repository.
///
/// This use case encapsulates the business logic for deleting a book
/// by ID, including fetching the book first to ensure it exists,
/// performing the deletion, and retrieving the updated list of books.
/// It provides logging for debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class DeleteBookUsecase {
  final IBookRepository bookRepository;

  DeleteBookUsecase({required this.bookRepository});

  final logger = Logger('DeleteBookUsecase');

  /// Deletes a book by BookIdPair and returns the updated list of books.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the book's BookIdPair for debugging purposes.
  /// 2. Fetches the book by BookIdPair to verify existence.
  /// 3. If the book exists, deletes it from the repository.
  /// 4. Retrieves the updated list of all books.
  /// 5. Logs success and the resulting book titles.
  /// 6. Returns the complete list of books after the deletion.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [bookIdPair] - The BookIdPair identifier of the book to be deleted.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all books on the right.
  Future<Either<Failure, List<Book>>> call({
    required BookIdPair bookIdPair,
  }) async {
    logger.info(
      'DeleteBookUsecase: Entering call with bookIdPair: $bookIdPair',
    );
    final getBooksEither = await bookRepository.getBooks();
    return getBooksEither.fold((failure) => Left(failure), (books) async {
      final book = books
          .where((b) => b.idPairs.idPairs.any((p) => p == bookIdPair))
          .firstOrNull;
      if (book == null) {
        return Left(NotFoundFailure('Book not found'));
      }
      logger.info(
        'DeleteBookUsecase: Deleting book: ${book.title} (idPairs: ${book.idPairs})',
      );
      final deleteEither = await bookRepository.deleteBook(book: book);
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedBooks = books
            .where((b) => !b.idPairs.idPairs.any((p) => p == bookIdPair))
            .toList();
        logger.info('DeleteBookUsecase: Success in call');
        logger.info(
          'DeleteBookUsecase: Output: ${updatedBooks.map((b) => '${b.title} (idPairs: ${b.idPairs})').toList()}',
        );
        logger.info('DeleteBookUsecase: Exiting call');
        return Right(updatedBooks);
      });
    });
  }
}
