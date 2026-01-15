import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving a book by BookIdPair.
class GetBookByIdPairUsecase with Loggable {
  final BookRepository bookRepository;

  GetBookByIdPairUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves a book by BookIdPair.
  Future<Either<Failure, Book>> call({required BookIdPair bookIdPair}) async {
    logger?.info(
      'getByIdPairpairUsecase: Entering call with bookIdPair: $bookIdPair',
    );
    final result = await bookRepository.getByIdPair(bookIdPair: bookIdPair);
    logger?.info('getByIdPairpairUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getByIdPairpairUsecase: Failure: $failure');
        return Left(failure);
      },
      (book) {
        logger?.info(
          'getByIdPairpairUsecase: Output: ${book.title} (businessIds: ${book.businessIds})',
        );
        return Right(book);
      },
    );
  }
}
