import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A domain entity representing book metadata.
class BookMetadata with EquatableMixin {
  /// The title of the book.
  final String? title;

  /// The description of the book.
  final String? description;

  /// The list of author names.
  final List<String>? authors;

  /// The published date of the book.
  final DateTime? publishedDate;

  /// The URL of the cover image.
  final String? coverImageUrl;

  /// The cover image data.
  final Uint8List? coverImage;

  /// Additional notes for the book.
  final String? notes;

  /// Creates a BookMetadata instance.
  const BookMetadata({
    this.title,
    this.description,
    this.authors,
    this.publishedDate,
    this.coverImageUrl,
    this.coverImage,
    this.notes,
  });

  /// Creates a copy of this BookMetadata with optional field updates.
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
