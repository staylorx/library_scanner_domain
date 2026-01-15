import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

import 'package:fpdart/fpdart.dart';

/// Use case for deleting a book from the repository.
class DeleteBookUsecase with Loggable {
  final BookRepository bookRepository;

  DeleteBookUsecase({Logger? logger, required this.bookRepository});

  /// Deletes a book by BookIdPair and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({
    required BookIdPair bookIdPair,
  }) async {
    logger?.info(
      'DeleteBookUsecase: Entering call with bookIdPair: $bookIdPair',
    );
    final getBooksEither = await bookRepository.getBooks();
    return getBooksEither.fold((failure) => Left(failure), (projections) async {
      final books = projections.map((p) => p.book).toList();
      final book = books
          .where((b) => b.businessIds.any((p) => p == bookIdPair))
          .firstOrNull;
      if (book == null) {
        return Left(NotFoundFailure('Book not found'));
      }
      logger?.info(
        'DeleteBookUsecase: Deleting book: ${book.title} (businessIds: ${book.businessIds})',
      );
      final deleteEither = await bookRepository.deleteBook(book: book);
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedBooks = books
            .where((b) => !b.businessIds.any((p) => p == bookIdPair))
            .toList();
        logger?.info('DeleteBookUsecase: Success in call');
        logger?.info(
          'DeleteBookUsecase: Output: ${updatedBooks.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
        );
        return Right(updatedBooks);
      });
    });
  }
}
