import 'dart:typed_data';

import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:uuid/uuid.dart';

/// A data model representing a book with its metadata and identifiers.
class BookModel {
  /// The unique identifier for the book, if assigned.
  final String? id;

  /// The list of identifier pairs for the book.
  final List<BookIdPair> idPairs;

  /// The title of the book.
  final String title;

  /// The original title of the book before cleaning.
  final String? originalTitle;

  /// The description of the book.
  final String? description;

  /// The list of author identifiers associated with the book.
  final List<String> authorIds;

  /// The list of tag identifiers associated with the book.
  final List<String> tagIds;

  /// The published date of the book.
  final DateTime? publishedDate;

  /// The cover image data of the book.
  final Uint8List? coverImage;

  /// The URL of the cover image.
  final String? coverImageUrl;

  /// Additional notes for the book.
  final String? notes;

  /// Creates a [BookModel] instance.
  const BookModel({
    this.id,
    required this.idPairs,
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

  /// Creates a [BookModel] from a map representation, handling legacy formats.
  factory BookModel.fromMap({required Map<String, dynamic> map}) {
    final idPairs =
        (map['idPairs'] as List<dynamic>?)?.map((e) {
          final idTypeString = e['idType'] as String? ?? 'none';
          BookIdType idType;
          try {
            idType = BookIdType.values.byName(idTypeString);
          } catch (_) {
            /// Handle legacy format where idType was stored as displayName.toLowerCase()
            switch (idTypeString) {
              case 'isbn-13':
                idType = BookIdType.isbn13;
                break;
              case 'isbn':
                idType = BookIdType.isbn;
                break;
              case 'asin':
                idType = BookIdType.asin;
                break;
              case 'doi':
                idType = BookIdType.doi;
                break;
              case 'ean':
                idType = BookIdType.ean;
                break;
              case 'local':
                idType = BookIdType.local;
                break;
              default:
                throw Exception('Unknown BookIdType: $idTypeString');
            }
          }
          return BookIdPair(idType: idType, idCode: e['idCode'] as String);
        }).toList() ??
        [];
    if (idPairs.isEmpty) {
      throw Exception('Book must have at least one BookIdPair');
    }
    return BookModel(
      id: map['id'] as String?,
      idPairs: idPairs,
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

  /// Converts this [BookModel] to a map representation.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'idPairs': idPairs
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

  /// Converts this [BookModel] to a [Book] domain entity.
  Book toEntity({required List<Author> authors, required List<Tag> tags}) {
    return Book(
      idPairs: BookIdPairs(idPairs),
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

  /// Creates a [BookModel] from a [Book] domain entity.
  factory BookModel.fromEntity({required Book book}) {
    /// Ensure book always has at least one BookIdPair
    final List<BookIdPair> effectiveIdPairs = book.idPairs.idPairs.isNotEmpty
        ? book.idPairs.idPairs
        : [BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4())];

    return BookModel(
      id: book.key,
      idPairs: effectiveIdPairs,
      title: book.title,
      originalTitle: book.originalTitle,
      description: book.description,
      authorIds: book.authors.map((a) => a.name).toList(),
      tagIds: book.tags.map((t) => t.name).toList(),
      publishedDate: book.publishedDate,
      coverImage: book.coverImage,
      coverImageUrl: null, // Entity doesn't have URL
      notes: book.notes,
    );
  }

  /// Creates a copy of this [BookModel] with optional field updates.
  BookModel copyWith({
    String? id,
    List<BookIdPair>? idPairs,
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
      idPairs: idPairs ?? this.idPairs,
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

  /// Converts this [BookModel] to [BookMetadata].
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
