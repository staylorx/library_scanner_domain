import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for retrieving all books from the repository.
class GetBooksUsecase {
  final IBookRepository bookRepository;

  GetBooksUsecase(this.bookRepository);

  final logger = DevLogger('GetBooksUsecase');

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
