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
