import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';
import '../value_objects/book_id.dart';
import 'author.dart';
import 'tag.dart';

/// A domain entity representing a book.
class Book with EquatableMixin {
  /// The set of identifier pairs for the book, representing various identification codes like ISBNs.
  final IdPairSet<BookIdPair> _idPairs;

  /// The title of the book.
  final String title;

  /// The original title of the book before cleaning.
  final String? originalTitle;

  /// The description of the book.
  final String? description;

  /// The list of authors of the book.
  final List<Author> authors;

  /// The list of tags associated with the book.
  final List<Tag> tags;

  /// The published date of the book.
  final DateTime? publishedDate;

  /// The cover image data of the book.
  final Uint8List? coverImage;

  /// Additional notes for the book.
  final String? notes;

  /// Creates a [Book] instance.
  Book({
    required IdPairSet<BookIdPair> idPairs,
    required this.title,
    this.originalTitle,
    this.description,
    required this.authors,
    required this.tags,
    this.publishedDate,
    this.coverImage,
    this.notes,
  }) : _idPairs = idPairs;

  /// The set of identifier pairs for the book.
  IdPairSet<BookIdPair> get idPairs => _idPairs;

  /// The key for the book, based on idPairs or title.
  String get key {
    final id = idPairs.toString();
    return id.isNotEmpty ? id : title;
  }

  /// Creates a copy of this [Book] with optional field updates.
  Book copyWith({
    IdPairSet<BookIdPair>? idPairs,
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
      idPairs: idPairs ?? this.idPairs,
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
  List<Object?> get props => [idPairs, title, originalTitle, description];
}
