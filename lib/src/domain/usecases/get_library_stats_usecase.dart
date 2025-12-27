import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Usecase for getting library statistics
class GetLibraryStatsUsecase {
  final GetBooksUsecase _getBooksUsecase;
  final GetAuthorsUsecase _getAuthorsUsecase;
  final GetTagsUsecase _getTagsUsecase;

  GetLibraryStatsUsecase({
    required GetBooksUsecase getBooksUsecase,
    required GetAuthorsUsecase getAuthorsUsecase,
    required GetTagsUsecase getTagsUsecase,
  }) : _getBooksUsecase = getBooksUsecase,
       _getAuthorsUsecase = getAuthorsUsecase,
       _getTagsUsecase = getTagsUsecase;

  /// Gets comprehensive library statistics.
  Future<Either<Failure, LibraryStats>> call() async {
    final booksResult = await _getBooksUsecase();
    return booksResult.fold((failure) => Future.value(Left(failure)), (
      books,
    ) async {
      final authorsResult = await _getAuthorsUsecase();
      return authorsResult.fold((failure) => Future.value(Left(failure)), (
        authors,
      ) async {
        final tagsResult = await _getTagsUsecase();
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

/// Data class for library statistics.
class LibraryStats {
  final int totalBooks;
  final int totalAuthors;
  final int totalTags;
  final int booksWithCovers;
  final Map<String, int> booksByTag;

  LibraryStats({
    required this.totalBooks,
    required this.totalAuthors,
    required this.totalTags,
    required this.booksWithCovers,
    required this.booksByTag,
  });

  double get coverPercentage =>
      totalBooks > 0 ? (booksWithCovers / totalBooks) * 100 : 0.0;
}
