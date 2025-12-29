/// Enum for sort direction
enum SortDirection {
  ascending('Ascending'),
  descending('Descending');

  const SortDirection(this.displayName);

  final String displayName;

  /// Returns the opposite sort direction.
  SortDirection get opposite {
    return this == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;
  }
}
