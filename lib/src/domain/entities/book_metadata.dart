import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Book metadata.
class BookMetadata with EquatableMixin {
  /// Book title.
  final String? title;

  /// Book description.
  final String? description;

  /// Author names.
  final List<String>? authors;

  /// Published date.
  final DateTime? publishedDate;

  /// Cover image URL.
  final String? coverImageUrl;

  /// Cover image data.
  final Uint8List? coverImage;

  /// Notes.
  final String? notes;

  /// Creates BookMetadata.
  const BookMetadata({
    this.title,
    this.description,
    this.authors,
    this.publishedDate,
    this.coverImageUrl,
    this.coverImage,
    this.notes,
  });

  /// Creates a copy with optional updates.
  BookMetadata copyWith({
    String? title,
    String? description,
    List<String>? authors,
    DateTime? publishedDate,
    String? coverImageUrl,
    Uint8List? coverImage,
    String? notes,
  }) {
    return BookMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      authors: authors ?? this.authors,
      publishedDate: publishedDate ?? this.publishedDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImage: coverImage ?? this.coverImage,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    authors,
    publishedDate,
    coverImageUrl,
    coverImage,
    notes,
  ];
}
