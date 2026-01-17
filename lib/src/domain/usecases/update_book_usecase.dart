import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating an existing book in the repository.
class UpdateBookUsecase with Loggable {
  final BookRepository bookRepository;

  UpdateBookUsecase({Logger? logger, required this.bookRepository});

  /// Updates an existing book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({required Book book}) async {
    logger?.info(
      'UpdateBookUsecase: Entering call with book: ${book.title} (businessIds: ${book.businessIds})',
    );
    final updateEither = await bookRepository.updateBook(book: book);
    return updateEither.fold((failure) => Future.value(Left(failure)), (
      _,
    ) async {
      final getEither = await bookRepository.getBooks();
      logger?.info('UpdateBookUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (books) {
        logger?.info(
          'UpdateBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
        );
        return Right(books);
      });
    });
  }
}
