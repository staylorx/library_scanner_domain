/// Enum for sort direction
enum SortDirection {
  ascending('Ascending'),
  descending('Descending');

  const SortDirection(this.displayName);

  final String displayName;

  SortDirection get opposite {
    return this == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;
  }
}
