import 'package:equatable/equatable.dart';
import 'author.dart';
import 'book.dart';
import 'tag.dart';

/// Library collection.
class Library with EquatableMixin {
  /// Library name.
  final String name;

  /// Library description.
  final String? description;

  /// Books in library.
  final List<Book> books;

  /// Authors in library.
  final List<Author> authors;

  /// Tags in library.
  final List<Tag> tags;

  /// Creates Library.
  const Library({
    required this.name,
    this.description,
    required this.books,
    required this.authors,
    required this.tags,
  });

  /// Creates a copy with optional updates.
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
