import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving a book by ID.
class GetBookByIdUsecase with Loggable {
  final BookRepository bookRepository;

  GetBookByIdUsecase({Logger? logger, required this.bookRepository});

  /// Retrieves a book by ID.
  TaskEither<Failure, Book> call({required String id}) {
    logger?.info('GetBookByIdUsecase: Entering call with id: $id');
    return bookRepository.getById(id: id).map((book) {
      logger?.info(
        'GetBookByIdUsecase: Output: ${book.title} (id: ${book.id})',
      );
      return book;
    });
  }
}
