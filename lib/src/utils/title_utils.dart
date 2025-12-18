/* Utility functions for title processing. */

/// Cleans up book titles by moving leading articles to the end,
/// followed by a comma. For example, "The Great Gatsby" becomes "Great Gatsby, The".
/// Handles case insensitivity and capitalizes the moved article.
/// Currently supports English articles by default. For other languages, provide custom articles.
/// Note: Original title should be saved separately for preservation.
String cleanBookTitle(
  String title, {
  List<String> articles = const ['the ', 'a ', 'an '],
}) {
  final lowerTitle = title.toLowerCase();
  for (final article in articles) {
    if (lowerTitle.startsWith(article.toLowerCase())) {
      final rest = title.substring(article.length);
      final movedArticle = title.substring(0, article.length).trim();
      // Capitalize the first letter of the moved article
      final capitalizedArticle =
          movedArticle[0].toUpperCase() +
          movedArticle.substring(1).toLowerCase();
      return '$rest, $capitalizedArticle';
    }
  }
  return title;
}
