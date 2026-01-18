import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of book metadata repository.
class BookMetadataRepositoryImpl
    with Loggable
    implements BookMetadataRepository {
  final BookApiService apiService;
  final ImageService imageService;

  /// Creates a BookMetadataRepositoryImpl instance.
  BookMetadataRepositoryImpl({
    required this.apiService,
    required this.imageService,
    Logger? logger,
  });

  /// Fetches book metadata by ISBN.
  @override
  Future<Either<Failure, BookMetadata>> fetchBookByIsbn({
    required String isbn,
    bool fetchCoverArt = true,
  }) async {
    final fetchEither = await apiService.fetchBookByIsbn(isbn: isbn);
    if (fetchEither.isLeft()) {
      return Left(
        fetchEither.getLeft().getOrElse(() => ServiceFailure('Unknown error')),
      );
    }

    final bookMetadata = fetchEither.getRight().getOrElse(() => null);
    if (bookMetadata == null) {
      return Left(NotFoundFailure('Book not found for ISBN: $isbn'));
    }
    if (bookMetadata.coverImageUrl == null) {
      return Right(bookMetadata);
    }

    if (!fetchCoverArt) {
      return Right(bookMetadata);
    }

    // Download the cover image bytes
    final downloadEither = await imageService.downloadImageBytesFromUrl(
      url: bookMetadata.coverImageUrl!,
    );
    if (downloadEither.isLeft()) {
      return Right(bookMetadata);
    }

    final bytes = downloadEither.getRight().getOrElse(() => Uint8List(0));
    if (bytes.isEmpty) return Right(bookMetadata);

    final thumbnailEither = await imageService.generateThumbnail(
      imageBytes: bytes,
    );
    if (thumbnailEither.isLeft()) {
      return Right(bookMetadata);
    }

    final coverImage = thumbnailEither.getRight().getOrElse(() => Uint8List(0));
    final updatedModel = bookMetadata.copyWith(coverImage: coverImage);
    return Right(updatedModel);
  }
}
