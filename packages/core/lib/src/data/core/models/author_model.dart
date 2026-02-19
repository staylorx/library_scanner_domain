import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Data model for an author.
class AuthorModel {
  /// Unique identifier.
  final String id;

  /// Business identifiers.
  final List<AuthorIdPair> businessIds;

  /// Author name.
  final String name;

  /// Author biography.
  final String? biography;

  /// Creates an AuthorModel.
  const AuthorModel({
    required this.id,
    required this.businessIds,
    required this.name,
    this.biography,
  });

  /// Creates from map.
  factory AuthorModel.fromMap({required Map<String, dynamic> map}) {
    final businessIdsList =
        (map['businessIds'] as List<dynamic>?)
            ?.map(
              (e) => AuthorIdPair(
                idType: AuthorIdType.values.byName(
                  e['idType'] as String? ?? 'local',
                ),
                idCode: e['idCode'] as String,
              ),
            )
            .toList() ??
        [];
    return AuthorModel(
      id: map['id'] as String,
      businessIds: businessIdsList,
      name: map['name'] as String,
      biography: map['biography'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessIds': businessIds
          .map((p) => {'idType': p.idType.name, 'idCode': p.idCode})
          .toList(),
      'name': name,
      'biography': biography,
    };
  }

  /// Converts to entity.
  Author toEntity() {
    return Author(
      id: id,
      businessIds: businessIds,
      name: name,
      biography: biography,
    );
  }

  /// Creates from entity.
  factory AuthorModel.fromEntity(Author author) {
    return AuthorModel(
      id: author.id,
      businessIds: author.businessIds,
      name: author.name,
      biography: author.biography,
    );
  }

  /// Creates a copy.
  AuthorModel copyWith({
    String? id,
    List<AuthorIdPair>? businessIds,
    String? name,
    String? biography,
  }) {
    return AuthorModel(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      name: name ?? this.name,
      biography: biography ?? this.biography,
    );
  }
}
