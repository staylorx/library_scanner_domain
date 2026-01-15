/// Sort direction.
enum SortDirection {
  ascending('Ascending'),
  descending('Descending');

  const SortDirection(this.displayName);

  /// Display name.
  final String displayName;

  /// Opposite sort direction.
  SortDirection get opposite {
    return this == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;
  }
}
