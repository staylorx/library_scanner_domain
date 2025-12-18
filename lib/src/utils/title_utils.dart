/* Utility functions for title processing. */

/// Cleans up book titles by moving leading articles ("The", "A", "An") to the end,
/// followed by a comma. For example, "The Great Gatsby" becomes "Great Gatsby, The".
// TODO: consider internationalization and other languages/articles. Require saving original title as well?
String cleanBookTitle(String title) {
  const articles = ['The ', 'A ', 'An '];
  for (final article in articles) {
    if (title.startsWith(article)) {
      final rest = title.substring(article.length);
      return '$rest, ${article.trim()}';
    }
  }
  return title;
}
