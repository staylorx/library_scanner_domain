import 'package:equatable/equatable.dart';
import 'author.dart';
import 'book.dart';
import 'tag.dart';

class Library with EquatableMixin {
  final String name;
  final String? description;
  final List<Book> books;
  final List<Author> authors;
  final List<Tag> tags;

  const Library({
    required this.name,
    this.description,
    required this.books,
    required this.authors,
    required this.tags,
  });

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
