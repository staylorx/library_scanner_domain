import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

import '../repositories/book_metadata_repository.dart';
import '../entities/book_metadata.dart';

/// Use case for fetching book metadata by ISBN, including cover art download if enabled.

class FetchBookMetadataByIsbnUsecase {
  final IBookMetadataRepository bookMetadataRepository;

  FetchBookMetadataByIsbnUsecase(this.bookMetadataRepository);

  final logger = DevLogger('FetchBookMetadataByIsbnUsecase');

  /// Fetches book metadata by ISBN.
  /// If fetch cover art is enabled, downloads the cover image locally.
  Future<Either<Failure, BookMetadata?>> call({required String isbn}) async {
    logger.info(
      'FetchBookMetadataByIsbnUsecase: Fetching metadata for ISBN $isbn',
    );

    return await bookMetadataRepository.fetchBookByIsbn(isbn: isbn);
  }
}
