import 'dart:typed_data';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for updating an existing book in the repository.
class UpdateBookUsecase with Loggable {
  final BookRepository bookRepository;

  UpdateBookUsecase({Logger? logger, required this.bookRepository});

  /// Updates an existing book and returns the updated list of books.
  Future<Either<Failure, List<Book>>> call({
    required String id,
    required String title,
    required List<Author> authors,
    List<Tag> tags = const [],
    String? description,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? notes,
    List<BookIdPair>? businessIds,
  }) async {
    logger?.info(
      'UpdateBookUsecase: Entering call with id: $id, title: $title',
    );
    final getEither = await bookRepository.getBookById(id: id);
    return getEither.fold((failure) => Left(failure), (existingBook) async {
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
      final updateEither = await bookRepository.updateBook(book: cleanedBook);
      return updateEither.fold((failure) => Future.value(Left(failure)), (
        _,
      ) async {
        final getBooksEither = await bookRepository.getBooks();
        logger?.info('UpdateBookUsecase: Success in call');
        return getBooksEither.fold((failure) => Left(failure), (books) {
          logger?.info(
            'UpdateBookUsecase: Output: ${books.map((b) => '${b.title} (businessIds: ${b.businessIds})').toList()}',
          );
          return Right(books);
        });
      });
    });
  }
}
