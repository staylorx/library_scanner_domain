import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case responsible for retrieving a single book by its BookIdPair.
///
/// This use case encapsulates the business logic for fetching a book
/// from the repository by BookIdPair. It provides logging for debugging and
/// error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetBookByIdPairUsecase with Loggable {
  final BookRepository bookRepository;

  GetBookByIdPairUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves a book by its unique BookIdPair.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the book's BookIdPair for debugging purposes.
  /// 2. Calls the repository to fetch the book by BookIdPair.
  /// 3. Logs success and the resulting book's title (or null if not found).
  /// 4. Returns the book entity or null if not found.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [bookIdPair] - The BookIdPair identifier of the book to retrieve.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the [Book] entity on the right.
  Future<Either<Failure, Book>> call({required BookIdPair bookIdPair}) async {
    logger?.info(
      'getByIdPairpairUsecase: Entering call with bookIdPair: $bookIdPair',
    );
    final result = await bookRepository.getByIdPair(bookIdPair: bookIdPair);
    logger?.info('getByIdPairpairUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getByIdPairpairUsecase: Failure: $failure');
        logger?.info('getByIdPairpairUsecase: Exiting call');
        return Left(failure);
      },
      (book) {
        logger?.info(
          'getByIdPairpairUsecase: Output: ${book.title} (businessIds: ${book.businessIds})',
        );
        logger?.info('getByIdPairpairUsecase: Exiting call');
        return Right(book);
      },
    );
  }
}
