import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../value_objects/book_id_pair.dart';
import 'author.dart';
import 'tag.dart';

/// Represents a book.
class Book with EquatableMixin {
  /// Entity identifier.
  final String id;

  /// Business identifiers.
  final List<BookIdPair> businessIds;

  /// Book title.
  final String title;

  /// Original title.
  final String? originalTitle;

  /// Book description.
  final String? description;

  /// Book authors.
  final List<Author> authors;

  /// Book tags.
  final List<Tag> tags;

  /// Published date.
  final DateTime? publishedDate;

  /// Cover image data.
  final Uint8List? coverImage;

  /// Notes.
  final String? notes;

  /// Creates Book.
  Book({
    required this.id,
    required this.businessIds,
    required this.title,
    this.originalTitle,
    this.description,
    required this.authors,
    required this.tags,
    this.publishedDate,
    this.coverImage,
    this.notes,
  });

  /// Creates a copy with optional updates.
  Book copyWith({
    String? id,
    List<BookIdPair>? businessIds,
    String? title,
    String? originalTitle,
    String? description,
    List<Author>? authors,
    List<Tag>? tags,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? notes,
  }) {
    return Book(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      description: description ?? this.description,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      publishedDate: publishedDate ?? this.publishedDate,
      coverImage: coverImage ?? this.coverImage,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessIds,
    title,
    originalTitle,
    description,
  ];
}
