enum BookIdType {
  isbn('ISBN'),
  isbn13('ISBN-13'),
  asin('ASIN'),
  doi('DOI'),
  ean('EAN'),
  local('LOCAL');

  const BookIdType(this.displayName);
  final String displayName;

  String get name => toString().split('.').last;
}
