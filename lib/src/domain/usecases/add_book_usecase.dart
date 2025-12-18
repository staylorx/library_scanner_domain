import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_pair_set/id_pair_set.dart';

import 'package:logging/logging.dart';

/// Use case for adding a new book to the repository.
class AddBookUsecase {
  final IBookRepository bookRepository;

  AddBookUsecase({required this.bookRepository});

  final logger = Logger('AddBookUsecase');

  /// Adds a new book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({required Book book}) async {
    List<BookIdPair> idPairs = book.idPairs.idPairs;
    if (idPairs.isEmpty) {
      // Generate a unique local ID
      final localId =
          'local-${DateTime.now().millisecondsSinceEpoch}-${book.title.hashCode}';
      idPairs.add(BookIdPair(idType: BookIdType.local, idCode: localId));
    }
    final cleanedBook = book.copyWith(
      title: cleanBookTitle(book.title),
      originalTitle: book.title,
      idPairs: IdPairSet(idPairs),
    );
    logger.info(
      'AddBookUsecase: Entering call with book: ${cleanedBook.title} (idPairs: ${cleanedBook.idPairs})',
    );
    final addEither = await bookRepository.addBook(book: cleanedBook);
    return addEither.fold((failure) => Future.value(Left(failure)), (_) async {
      final getEither = await bookRepository.getBooks();
      logger.info('AddBookUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (books) {
        logger.info(
          'AddBookUsecase: Output: ${books.map((b) => '${b.title} (idPairs: ${b.idPairs})').toList()}',
        );
        logger.info('AddBookUsecase: Exiting call');
        return Right(books);
      });
    });
  }
}
