import 'dart:typed_data';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new book to the repository.
class AddBookUsecase with Loggable {
  final BookRepository bookRepository;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;
  final BookIdRegistryService bookIdRegistryService;

  AddBookUsecase({
    Logger? logger,
    required this.bookRepository,
    required this.isBookDuplicateUsecase,
    required this.bookIdRegistryService,
  });

  /// Adds a new book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({
    required String title,
    required List<Author> authors,
    List<Tag> tags = const [],
    String? description,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? notes,
    List<BookIdPair>? businessIds,
  }) async {
    final id = const Uuid().v4();
    List<BookIdPair> finalBusinessIds = businessIds ?? [];
    if (finalBusinessIds.isEmpty) {
      // Generate a unique local ID
      final localIdEither = await bookIdRegistryService.generateLocalId();
      if (localIdEither.isLeft()) {
        return Left(
          localIdEither.getLeft().getOrElse(
            () => DatabaseFailure('Failed to generate local ID'),
          ),
        );
      }
      final localId = localIdEither.getRight().getOrElse(() => '');
      finalBusinessIds = [
        BookIdPair(idType: BookIdType.local, idCode: localId),
      ];
    }
    final book = Book(
      id: id,
      businessIds: finalBusinessIds,
      title: title,
      originalTitle: title,
      description: description,
      authors: authors,
      tags: tags,
      publishedDate: publishedDate,
      coverImage: coverImage,
      notes: notes,
    );
    final cleanedBook = book.copyWith(title: cleanBookTitle(title: book.title));
    logger?.info(
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
      (existing) => isBookDuplicateUsecase(
        bookA: cleanedBook,
        bookB: existing,
      ).getRight().getOrElse(() => false),
    );
    if (isDuplicate) {
      logger?.warning(
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
      logger?.info('AddBookUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (books) {
        logger?.info(
          'AddBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
        );
        return Right(books);
      });
    });
  }
}
