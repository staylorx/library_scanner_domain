import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class BookMetadataRepositoryImpl implements AbstractBookMetadataRepository {
  final AbstractBookApiService apiService;
  final AbstractImageService imageService;
  final AbstractSettingsService settingsService;

  BookMetadataRepositoryImpl({
    required this.apiService,
    required this.imageService,
    required this.settingsService,
  });

  @override
  Future<Either<Failure, BookMetadata?>> fetchBookByIsbn({
    required String isbn,
  }) async {
    final fetchEither = await apiService.fetchBookByIsbn(isbn: isbn);
    if (fetchEither.isLeft()) {
      return Left(
        fetchEither.getLeft().getOrElse(() => ServiceFailure('Unknown error')),
      );
    }

    final bookModel = fetchEither.getRight().getOrElse(() => null);
    if (bookModel == null || bookModel.coverImageUrl == null) {
      return Right(bookModel?.toBookMetadata());
    }

    // Check if fetch cover art is enabled
    final settingsEither = await settingsService.getFetchCoverArt();
    final fetchCoverArt = settingsEither.getOrElse((failure) => true);

    if (!fetchCoverArt) {
      return Right(bookModel.toBookMetadata());
    }

    // Download the cover image bytes
    final downloadEither = await imageService.downloadImageBytesFromUrl(
      url: bookModel.coverImageUrl!,
    );
    if (downloadEither.isLeft()) {
      return Right(bookModel.toBookMetadata());
    }

    final bytes = downloadEither.getRight().getOrElse(() => Uint8List(0));
    if (bytes.isEmpty) return Right(bookModel.toBookMetadata());

    final thumbnailEither = await imageService.generateThumbnail(
      imageBytes: bytes,
    );
    if (thumbnailEither.isLeft()) {
      return Right(bookModel.toBookMetadata());
    }

    final coverImage = thumbnailEither.getRight().getOrElse(() => Uint8List(0));
    final updatedModel = bookModel.copyWith(coverImage: coverImage);
    return Right(updatedModel.toBookMetadata());
  }
}
