enum AuthorIdType {
  isni('ISNI'),
  orcid('ORCID'),
  viaf('VIAF'),
  local('LOCAL');

  const AuthorIdType(this.displayName);
  final String displayName;
}
