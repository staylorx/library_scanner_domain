import 'package:equatable/equatable.dart';
import 'author.dart';
import 'book.dart';
import 'tag.dart';

/// A domain entity representing a library collection.
class Library with EquatableMixin {
  /// The name of the library.
  final String name;

  /// The description of the library.
  final String? description;

  /// The list of books in the library.
  final List<Book> books;

  /// The list of authors in the library.
  final List<Author> authors;

  /// The list of tags in the library.
  final List<Tag> tags;

  /// Creates a Library instance.
  const Library({
    required this.name,
    this.description,
    required this.books,
    required this.authors,
    required this.tags,
  });

  /// Creates a copy of this Library with optional field updates.
  Library copyWith({
    String? name,
    String? description,
    List<Book>? books,
    List<Author>? authors,
    List<Tag>? tags,
  }) {
    return Library(
      name: name ?? this.name,
      description: description ?? this.description,
      books: books ?? this.books,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [name, description, books, authors, tags];
}
