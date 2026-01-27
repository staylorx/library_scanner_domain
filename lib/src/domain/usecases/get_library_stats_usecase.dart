import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:id_logging/id_logging.dart';

/// Usecase for getting library statistics
class GetLibraryStatsUsecase with Loggable {
  final LibraryDataAccess dataAccess;

  GetLibraryStatsUsecase({Logger? logger, required this.dataAccess});

  // TODO: better to chain?

  /// Gets comprehensive library statistics.
  TaskEither<Failure, LibraryStats> call() {
    return dataAccess.bookRepository.getBooks().flatMap((books) {
      return dataAccess.authorRepository.getAll().flatMap((authors) {
        return dataAccess.tagRepository.getAll().map((tags) {
          return LibraryStats(
            totalBooks: books.length,
            totalAuthors: authors.length,
            totalTags: tags.length,
            booksWithCovers: books
                .where((book) => book.coverImage != null)
                .length,
            booksByTag: _calculateBooksByTag(books, tags),
          );
        });
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
