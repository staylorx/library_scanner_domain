import 'dart:typed_data';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating an existing book in the repository.
class UpdateBookUsecase with Loggable {
  final BookRepository bookRepository;

  UpdateBookUsecase({Logger? logger, required this.bookRepository});

  /// Updates an existing book and returns the updated list of books.
  TaskEither<Failure, List<Book>> call({
    required String id,
    required String title,
    required List<Author> authors,
    List<Tag> tags = const [],
    String? description,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? notes,
    List<BookIdPair>? businessIds,
  }) {
    logger?.info(
      'UpdateBookUsecase: Entering call with id: $id, title: $title',
    );
    return bookRepository.getBookById(id: id).flatMap((existingBook) {
      final finalBusinessIds = businessIds ?? existingBook.businessIds;
      final updatedBook = existingBook.copyWith(
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
      final cleanedBook = updatedBook.copyWith(
        title: cleanBookTitle(title: updatedBook.title),
      );
      return bookRepository.updateBook(book: cleanedBook).flatMap((_) {
        return bookRepository.getBooks().map((books) {
          logger?.info('UpdateBookUsecase: Success in call');
          logger?.info(
            'UpdateBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
          );
          return books;
        });
      });
    });
  }
}
