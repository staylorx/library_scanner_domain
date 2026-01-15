import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving all books from the repository.
class GetBooksUsecase with Loggable {
  final BookRepository bookRepository;

  GetBooksUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves all books from the repository.
  Future<Either<Failure, List<Book>>> call() async {
    logger?.info('GetBooksUsecase: Entering call');
    final result = await bookRepository.getBooks();
    logger?.info('GetBooksUsecase: Success in call');
    return result.fold((failure) => Left(failure), (books) {
      logger?.info(
        'GetBooksUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
      );
      logger?.info('GetBooksUsecase: Exiting call');
      return Right(books);
    });
  }
}
