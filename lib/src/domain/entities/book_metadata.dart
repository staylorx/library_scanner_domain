import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class BookMetadata with EquatableMixin {
  final String? title;
  final String? description;
  final List<String>? authors;
  final DateTime? publishedDate;
  final String? coverImageUrl;
  final Uint8List? coverImage;
  final String? notes;

  const BookMetadata({
    this.title,
    this.description,
    this.authors,
    this.publishedDate,
    this.coverImageUrl,
    this.coverImage,
    this.notes,
  });

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
