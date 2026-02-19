enum BookIdType {
  isbn10('ISBN-10'),
  isbn13('ISBN-13'),
  asin('ASIN'),
  doi('DOI'),
  ean('EAN'),
  upc("UPC"),
  local('LOCAL');

  const BookIdType(this.displayName);
  final String displayName;

  String get name => toString().split('.').last;
}
