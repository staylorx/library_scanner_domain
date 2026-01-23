import 'dart:typed_data';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new book to the repository.
class AddBookUsecase with Loggable {
  final BookRepository bookRepository;
  final IsBookDuplicateUsecase isBookDuplicateUsecase;

  AddBookUsecase({
    Logger? logger,
    required this.bookRepository,
    required this.isBookDuplicateUsecase,
  });

  /// Adds a new book and returns the updated list of books.
  TaskEither<Failure, List<Book>> call({
    required String title,
    required List<Author> authors,
    List<Tag> tags = const [],
    String? description,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? notes,
    List<BookIdPair>? businessIds,
  }) {
    final id = const Uuid().v4();
    final finalBusinessIds = businessIds ?? [];
    return _createBookAndAdd(
      id: id,
      title: title,
      authors: authors,
      tags: tags,
      description: description,
      publishedDate: publishedDate,
      coverImage: coverImage,
      notes: notes,
      finalBusinessIds: finalBusinessIds,
    );
  }

  TaskEither<Failure, List<Book>> _createBookAndAdd({
    required String id,
    required String title,
    required List<Author> authors,
    required List<Tag> tags,
    required String? description,
    required DateTime? publishedDate,
    required Uint8List? coverImage,
    required String? notes,
    required List<BookIdPair> finalBusinessIds,
  }) {
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
    logger?.info(
      'AddBookUsecase: Entering call with book: ${book.title} (businessIds: ${book.businessIds})',
    );

    // Check for duplicates
    return bookRepository.getBooks().flatMap((existingBooks) {
      final isDuplicate = existingBooks.any(
        (existing) => isBookDuplicateUsecase(
          bookA: book,
          bookB: existing,
        ).fold((failure) => false, (isDup) => isDup),
      );
      if (isDuplicate) {
        logger?.warning(
          'AddBookUsecase: Duplicate book detected: ${book.title}',
        );
        return TaskEither.left(
          ValidationFailure(
            'A book with the same title, authors, and ID pairs already exists',
          ),
        );
      }

      return bookRepository.addBook(book: book).flatMap((_) {
        return bookRepository.getBooks().map((books) {
          logger?.info(
            'AddBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
          );
          return books;
        });
      });
    });
  }
}
