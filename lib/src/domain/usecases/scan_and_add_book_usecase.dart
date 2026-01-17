import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

/// Usecase for scanning and adding a book by ISBN
class ScanAndAddBookUsecase with Loggable {
  final FetchBookMetadataByIsbnUsecase _fetchMetadataUsecase;
  final AddBookUsecase _addBookUsecase;
  final GetBookByIdPairUsecase _getByIdPairUsecase;

  ScanAndAddBookUsecase({
    Logger? logger,
    required FetchBookMetadataByIsbnUsecase fetchMetadataUsecase,
    required AddBookUsecase addBookUsecase,
    required GetBookByIdPairUsecase getByIdPairUsecase,
  }) : _fetchMetadataUsecase = fetchMetadataUsecase,
       _addBookUsecase = addBookUsecase,
       _getByIdPairUsecase = getByIdPairUsecase;

  /// Scans a book by ISBN and creates it in the library.
  Future<Either<Failure, Book>> call(String isbn) async {
    return _validateIsbn(isbn).fold((failure) => Future.value(Left(failure)), (
      validIsbn,
    ) async {
      final duplicateCheck = await _checkForDuplicate(validIsbn);
      return duplicateCheck.fold((failure) => Future.value(Left(failure)), (
        isDuplicate,
      ) async {
        if (isDuplicate) {
          return Left(
            ValidationFailure(
              'Book with ISBN $validIsbn already exists in library',
            ),
          );
        }
        final metadataResult = await _fetchMetadataUsecase(isbn: validIsbn);
        return metadataResult.fold((failure) => Left(failure), (
          metadata,
        ) async {
          if (metadata == null) {
            return Left(
              ValidationFailure('No metadata found for ISBN $validIsbn'),
            );
          }
          final book = _createBookFromMetadata(metadata, validIsbn);
          final addResult = await _addBookUsecase(
            title: book.title,
            authors: book.authors,
            tags: book.tags,
            description: book.description,
            publishedDate: book.publishedDate,
            coverImage: book.coverImage,
            notes: book.notes,
            businessIds: book.businessIds,
          );
          return addResult.map((books) => books.last);
        });
      });
    });
  }

  /// Validates ISBN format (basic validation).
  Either<Failure, String> _validateIsbn(String isbn) {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[^\dX]'), '');
    if (cleanIsbn.length != 10 && cleanIsbn.length != 13) {
      return Left(ValidationFailure('Invalid ISBN format'));
    }
    return Right(cleanIsbn);
  }

  /// Checks if a book with the given ISBN already exists.
  Future<Either<Failure, bool>> _checkForDuplicate(String isbn) async {
    final result = await _getByIdPairUsecase(
      bookIdPair: BookIdPair(idType: BookIdType.isbn, idCode: isbn),
    );
    return result.fold(
      (failure) => Right(false), // not found, no duplicate
      (book) => Right(true), // found, duplicate
    );
  }

  /// Creates a Book entity from fetched metadata.
  Book _createBookFromMetadata(BookMetadata metadata, String isbn) {
    return Book(
      id: const Uuid().v4(),
      businessIds: [BookIdPair(idType: BookIdType.isbn, idCode: isbn)],
      title: metadata.title ?? 'Unknown Title',
      authors:
          metadata.authors
              ?.map(
                (name) =>
                    Author(businessIds: [], name: name, id: const Uuid().v4()),
              )
              .toList() ??
          [],
      tags: [],
      publishedDate: metadata.publishedDate ?? DateTime.now(),
      description: '',
    );
  }
}
