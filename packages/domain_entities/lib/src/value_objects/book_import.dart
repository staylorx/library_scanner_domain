import 'package:domain_entities/domain_entities.dart';

class BookParseParams {
  final dynamic yamlBooks;
  final Map<String, Author> authorMap;
  final List<Tag> tags;

  BookParseParams(this.yamlBooks, this.authorMap, this.tags);
}

class BookParseResult {
  final List<Book> books;
  final List<String> errors;
  final List<String> missingAuthors;

  BookParseResult(this.books, this.errors, this.missingAuthors);
}

class BookProcessingResult {
  final List<Book> books;
  final List<String> warnings;
  final List<String> parseErrors;

  BookProcessingResult(this.books, this.warnings, this.parseErrors);
}

class DuplicateFilterResult {
  final List<Book> books;
  final List<String> warnings;

  DuplicateFilterResult(this.books, this.warnings);
}
