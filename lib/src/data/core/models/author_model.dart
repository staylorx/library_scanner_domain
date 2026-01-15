import 'package:library_scanner_domain/library_scanner_domain.dart';

/// A data model representing an author with their metadata and identifiers.
class AuthorModel {
  /// The unique identifier for the author.
  final String id;

  /// The business identifiers for the author.
  final List<AuthorIdPair> businessIds;

  /// The name of the author.
  final String name;

  /// The biography of the author.
  final String? biography;

  /// Creates an [AuthorModel] instance.
  const AuthorModel({
    required this.id,
    required this.businessIds,
    required this.name,
    this.biography,
  });

  /// Creates an [AuthorModel] from a map representation.
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

  /// Converts this [AuthorModel] to a map representation.
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

  /// Converts this [AuthorModel] to an [Author] domain entity.
  Author toEntity() {
    return Author(businessIds: businessIds, name: name, biography: biography);
  }

  /// Creates an [AuthorModel] from an [Author] domain entity and handle.
  factory AuthorModel.fromEntity(Author author, String handleId) {
    return AuthorModel(
      id: author.name,
      businessIds: author.businessIds,
      name: author.name,
      biography: author.biography,
    );
  }

  /// Creates a copy of this [AuthorModel] with optional field updates.
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
