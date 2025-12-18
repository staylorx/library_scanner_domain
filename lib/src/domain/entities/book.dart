import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';
import '../value_objects/book_id.dart';
import 'author.dart';
import 'tag.dart';

class Book with EquatableMixin {
  // ids represent various identification codes for the book;
  // for instance, industry standard numbers like ISBNs.
  final IdPairSet<BookIdPair> _idPairs;
  final String title;
  final String? description;
  final List<Author> authors;
  final List<Tag> tags;
  final DateTime? publishedDate;
  final Uint8List? coverImage;
  final String? notes;

  Book({
    required IdPairSet<BookIdPair> idPairs,
    required this.title,
    this.description,
    required this.authors,
    required this.tags,
    this.publishedDate,
    this.coverImage,
    this.notes,
  }) : _idPairs = idPairs;

  IdPairSet<BookIdPair> get idPairs => _idPairs;

  String get key {
    final id = idPairs.toString();
    return id.isNotEmpty ? id : title;
  }

  Book copyWith({
    IdPairSet<BookIdPair>? idPairs,
    String? title,
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
      description: description ?? this.description,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      publishedDate: publishedDate ?? this.publishedDate,
      coverImage: coverImage ?? this.coverImage,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [idPairs, title, description];
}
