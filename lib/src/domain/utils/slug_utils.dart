/// Computes a slug from a string.
String computeSlug(String input) {
  var slug = input
      .toLowerCase()
      .replaceAll(
        RegExp(r'[^a-z0-9\s-]'),
        '',
      ) // Remove special chars except spaces and hyphens
      .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
      .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
      .trim();
  if (slug.startsWith('-')) slug = slug.substring(1);
  if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
  return slug;
}
