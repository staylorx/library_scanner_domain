import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case for retrieving all books from the repository.
class GetBooksUsecase {
  final IBookRepository bookRepository;

  GetBooksUsecase({required this.bookRepository});

  final logger = Logger('GetBooksUsecase');

  /// Retrieves all books from the repository.
  Future<Either<Failure, List<Book>>> call() async {
    logger.info('GetBooksUsecase: Entering call');
    final result = await bookRepository.getBooks();
    logger.info('GetBooksUsecase: Success in call');
    return result.fold((failure) => Left(failure), (books) {
      logger.info(
        'GetBooksUsecase: Output: ${books.map((b) => '${b.title} (idPairs: ${b.idPairs})').toList()}',
      );
      logger.info('GetBooksUsecase: Exiting call');
      return Right(books);
    });
  }
}
