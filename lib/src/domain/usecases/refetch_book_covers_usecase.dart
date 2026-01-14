import 'dart:typed_data';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for refetching book covers from the API.
///
/// This use case retrieves all books from the repository, checks for books
/// with ISBNs, and refetches their cover images if overwrite is true or if
/// the cover image is missing. It handles errors gracefully by skipping
/// failed fetches and provides a success message with the count of updated books.
class RefetchBookCoversUsecase {
  final AbstractBookRepository bookRepository;
  final FetchBookMetadataByIsbnUsecase fetchBookMetadataByIsbnUsecase;
  final AbstractImageService imageService;

  RefetchBookCoversUsecase({
    required this.bookRepository,
    required this.fetchBookMetadataByIsbnUsecase,
    required this.imageService,
  });

  final logger = Logger('RefetchBookCoversUsecase');

  /// Refetches book covers based on the overwrite flag.
  ///
  /// [overwrite] - If true, refetches covers even if they already exist.
  /// Returns [Either<Failure, String>] with a success message on the right.
  Future<Either<Failure, String>> call({required bool overwrite}) async {
    logger.info(
      'RefetchBookCoversUsecase: Entering call with overwrite=$overwrite',
    );

    final booksEither = await bookRepository.getBooks();
    return booksEither.fold(
      (failure) {
        logger.info('RefetchBookCoversUsecase: Failed to get books: $failure');
        return Left(failure);
      },
      (books) async {
        int updatedCount = 0;
        for (final book in books) {
          if (book.businessIds.any((p) => p.idType == BookIdType.isbn)) {
            final isbn = book.businessIds
                .firstWhere((p) => p.idType == BookIdType.isbn)
                .idCode;
            if (overwrite || book.coverImage == null) {
              final fetchEither = await fetchBookMetadataByIsbnUsecase(
                isbn: isbn,
              );
              await fetchEither.fold(
                (failure) async {
                  logger.info(
                    'RefetchBookCoversUsecase: Failed to fetch for ISBN $isbn: $failure',
                  );
                  // Skip on failure
                },
                (bookModel) async {
                  if (bookModel != null && bookModel.coverImageUrl != null) {
                    // Download image bytes to generate thumbnail
                    final bytesEither = await imageService
                        .downloadImageBytesFromUrl(
                          url: bookModel.coverImageUrl!,
                        );
                    Uint8List? coverImage;
                    if (bytesEither.isRight()) {
                      final bytes = bytesEither.getRight().getOrElse(
                        () => Uint8List(0),
                      );
                      final thumbnailEither = await imageService
                          .generateThumbnail(imageBytes: bytes);
                      if (thumbnailEither.isRight()) {
                        coverImage = thumbnailEither.getRight().getOrElse(
                          () => Uint8List(0),
                        );
                        logger.info('Generated thumbnail for ${book.title}');
                      } else {
                        logger.info(
                          'Failed to generate thumbnail for ${book.title}',
                        );
                      }
                    } else {
                      logger.info(
                        'Failed to download image bytes for ${book.title}',
                      );
                    }

                    final updatedBook = book.copyWith(coverImage: coverImage);
                    final updateEither = await bookRepository.updateBook(
                      book: updatedBook,
                    );
                    updateEither.fold(
                      (updateFailure) {
                        logger.info(
                          'RefetchBookCoversUsecase: Failed to update book ${book.title}: $updateFailure',
                        );
                      },
                      (_) {
                        updatedCount++;
                        logger.info(
                          'RefetchBookCoversUsecase: Updated cover for ${book.title}',
                        );
                      },
                    );
                  }
                },
              );
            }
          }
        }
        final message = 'Successfully refetched covers for $updatedCount books';
        logger.info('RefetchBookCoversUsecase: $message');
        return Right(message);
      },
    );
  }
}
