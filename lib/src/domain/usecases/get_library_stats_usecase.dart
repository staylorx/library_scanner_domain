import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

/// Usecase for getting library statistics
class GetLibraryStatsUsecase with Loggable {
  final LibraryDataAccess _dataAccess;

  GetLibraryStatsUsecase({
    Logger? logger,
    required LibraryDataAccess dataAccess,
  }) : _dataAccess = dataAccess;

  /// Gets comprehensive library statistics.
  Future<Either<Failure, LibraryStats>> call() async {
    final booksResult = await _dataAccess.bookRepository.getBooks();
    return booksResult.fold((failure) => Future.value(Left(failure)), (
      books,
    ) async {
      final authorsResult = await _dataAccess.authorRepository.getAuthors();
      return authorsResult.fold((failure) => Future.value(Left(failure)), (
        authors,
      ) async {
        final tagsResult = await _dataAccess.tagRepository.getTags();
        return tagsResult.fold(
          (failure) => Future.value(Left(failure)),
          (tags) => Right(
            LibraryStats(
              totalBooks: books.length,
              totalAuthors: authors.length,
              totalTags: tags.length,
              booksWithCovers: books
                  .where((book) => book.coverImage != null)
                  .length,
              booksByTag: _calculateBooksByTag(books, tags),
            ),
          ),
        );
      });
    });
  }

  /// Calculates distribution of books by tag.
  Map<String, int> _calculateBooksByTag(List<Book> books, List<Tag> tags) {
    final result = <String, int>{};
    for (final tag in tags) {
      final count = books
          .where((book) => book.tags.any((t) => t.name == tag.name))
          .length;
      if (count > 0) {
        result[tag.name] = count;
      }
    }
    return result;
  }
}
