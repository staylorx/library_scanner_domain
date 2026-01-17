import 'dart:typed_data';

import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Parses BookIdType from string.
BookIdType _parseBookIdType(String idTypeString) {
  // Try modern format first
  try {
    return BookIdType.values.byName(idTypeString);
  } catch (_) {
    // Handle legacy format where idType was stored as displayName.toLowerCase()
    switch (idTypeString) {
      case 'isbn-13':
        return BookIdType.isbn13;
      case 'isbn':
        return BookIdType.isbn;
      case 'asin':
        return BookIdType.asin;
      case 'doi':
        return BookIdType.doi;
      case 'ean':
        return BookIdType.ean;
      case 'local':
        return BookIdType.local;
      default:
        throw Exception('Unknown BookIdType: $idTypeString');
    }
  }
}

/// Data model for a book.
class BookModel {
  /// Unique identifier.
  final String id;

  /// Business identifiers.
  final List<BookIdPair> businessIds;

  /// Book title.
  final String title;

  /// Original title.
  final String? originalTitle;

  /// Book description.
  final String? description;

  /// Author identifiers.
  final List<String> authorIds;

  /// Tag identifiers.
  final List<String> tagIds;

  /// Published date.
  final DateTime? publishedDate;

  /// Cover image data.
  final Uint8List? coverImage;

  /// Cover image URL.
  final String? coverImageUrl;

  /// Additional notes.
  final String? notes;

  /// Creates a BookModel.
  const BookModel({
    required this.id,
    required this.businessIds,
    required this.title,
    this.originalTitle,
    this.description,
    required this.authorIds,
    required this.tagIds,
    this.publishedDate,
    this.coverImage,
    this.coverImageUrl,
    this.notes,
  });

  /// Creates from map.
  factory BookModel.fromMap({required Map<String, dynamic> map}) {
    final businessIds =
        (map['businessIds'] as List<dynamic>?)?.map((e) {
          final idTypeString = e['idType'] as String? ?? 'none';
          final idType = _parseBookIdType(idTypeString);
          return BookIdPair(idType: idType, idCode: e['idCode'] as String);
        }).toList() ??
        [];
    return BookModel(
      id: map['id'] as String,
      businessIds: businessIds,
      title: map['title'] as String,
      originalTitle: map['originalTitle'] as String?,
      description: map['description'] as String?,
      authorIds: (map['authorIds'] as List<dynamic>?)?.cast<String>() ?? [],
      tagIds: (map['tagIds'] as List<dynamic>?)?.cast<String>() ?? [],
      publishedDate: map['publishedDate'] != null
          ? DateTime.parse(map['publishedDate'] as String)
          : null,
      coverImage: map['coverImage'] != null
          ? Uint8List.fromList((map['coverImage'] as List).cast<int>())
          : null,
      coverImageUrl: map['coverImageUrl'] as String?,
      notes: map['notes'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessIds': businessIds
          .map((p) => {'idType': p.idType.name, 'idCode': p.idCode})
          .toList(),
      'title': title,
      'originalTitle': originalTitle,
      'description': description,
      'authorIds': authorIds,
      'tagIds': tagIds,
      'publishedDate': publishedDate?.toIso8601String(),
      'coverImage': coverImage,
      'coverImageUrl': coverImageUrl,
      'notes': notes,
    };
  }

  /// Converts to entity.
  Book toEntity({required List<Author> authors, required List<Tag> tags}) {
    return Book(
      id: id,
      businessIds: businessIds,
      title: title,
      originalTitle: originalTitle,
      description: description,
      authors: authors,
      tags: tags,
      publishedDate: publishedDate,
      coverImage: coverImage,
      notes: notes,
    );
  }

  /// Creates from entity.
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      businessIds: book.businessIds,
      title: book.title,
      originalTitle: book.originalTitle,
      description: book.description,
      authorIds: book.authors.map((a) => a.id).toList(),
      tagIds: book.tags.map((t) => t.id).toList(),
      publishedDate: book.publishedDate,
      coverImage: book.coverImage,
      coverImageUrl: null, // Entity doesn't have URL
      notes: book.notes,
    );
  }

  /// Creates a copy.
  BookModel copyWith({
    String? id,
    List<BookIdPair>? businessIds,
    String? title,
    String? originalTitle,
    String? description,
    List<String>? authorIds,
    List<String>? tagIds,
    DateTime? publishedDate,
    Uint8List? coverImage,
    String? coverImageUrl,
    String? notes,
  }) {
    return BookModel(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      description: description ?? this.description,
      authorIds: authorIds ?? this.authorIds,
      tagIds: tagIds ?? this.tagIds,
      publishedDate: publishedDate ?? this.publishedDate,
      coverImage: coverImage ?? this.coverImage,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      notes: notes ?? this.notes,
    );
  }

  /// Converts to BookMetadata.
  BookMetadata toBookMetadata() {
    return BookMetadata(
      title: title,
      description: description,
      authors: authorIds,
      publishedDate: publishedDate,
      coverImageUrl: coverImageUrl,
      coverImage: coverImage,
      notes: notes,
    );
  }
}
