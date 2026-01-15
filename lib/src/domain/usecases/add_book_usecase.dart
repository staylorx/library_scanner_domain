import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import 'package:logging/logging.dart';

/// Use case for adding a new book to the repository.
class AddBookUsecase {
  final BookRepository bookRepository;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;

  AddBookUsecase({
    required this.bookRepository,
    required this.isBookDuplicateUsecase,
  });

  final logger = Logger('AddBookUsecase');

  /// Adds a new book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({required Book book}) async {
    List<BookIdPair> businessIds = book.businessIds;
    if (businessIds.isEmpty) {
      // Generate a unique local ID
      final localId =
          'local-${DateTime.now().millisecondsSinceEpoch}-${book.title.hashCode}';
      businessIds = [
        ...businessIds,
        BookIdPair(idType: BookIdType.local, idCode: localId),
      ];
    }
    final cleanedBook = book.copyWith(
      title: cleanBookTitle(title: book.title),
      originalTitle: book.title,
      businessIds: businessIds,
    );
    logger.info(
      'AddBookUsecase: Entering call with book: ${cleanedBook.title} (businessIds: ${cleanedBook.businessIds})',
    );

    // Check for duplicates
    final existingBooksEither = await bookRepository.getBooks();
    if (existingBooksEither.isLeft()) {
      return Left(
        existingBooksEither.getLeft().getOrElse(
          () => DatabaseFailure('Failed to check existing books'),
        ),
      );
    }
    final existingBooks = existingBooksEither.getRight().getOrElse(() => []);
    final isDuplicate = existingBooks.any(
      (existing) => isBookDuplicateUsecase
          .call(bookA: cleanedBook, bookB: existing)
          .getRight()
          .getOrElse(() => false),
    );
    if (isDuplicate) {
      logger.warning(
        'AddBookUsecase: Duplicate book detected: ${cleanedBook.title}',
      );
      return Left(
        ValidationFailure(
          'A book with the same title, authors, and ID pairs already exists',
        ),
      );
    }

    final addEither = await bookRepository.addBook(book: cleanedBook);
    return addEither.fold((failure) => Future.value(Left(failure)), (_) async {
      final getEither = await bookRepository.getBooks();
      logger.info('AddBookUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (books) {
        logger.info(
          'AddBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
        );
        logger.info('AddBookUsecase: Exiting call');
        return Right(books);
      });
    });
  }
}
