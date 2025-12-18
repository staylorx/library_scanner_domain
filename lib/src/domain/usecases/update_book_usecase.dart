import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case for updating an existing book in the repository.
class UpdateBookUsecase {
  final AbstractBookRepository bookRepository;

  UpdateBookUsecase({required this.bookRepository});

  final logger = Logger('UpdateBookUsecase');

  /// Updates an existing book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({required Book book}) async {
    logger.info(
      'UpdateBookUsecase: Entering call with book: ${book.title} (idPairs: ${book.idPairs})',
    );
    final updateEither = await bookRepository.updateBook(book: book);
    return updateEither.fold((failure) => Future.value(Left(failure)), (
      _,
    ) async {
      final getEither = await bookRepository.getBooks();
      logger.info('UpdateBookUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (books) {
        logger.info(
          'UpdateBookUsecase: Output: ${books.map((b) => '${b.title} (idPairs: ${b.idPairs})').toList()}',
        );
        logger.info('UpdateBookUsecase: Exiting call');
        return Right(books);
      });
    });
  }
}
