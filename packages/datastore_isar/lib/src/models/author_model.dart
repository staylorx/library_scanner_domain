import 'package:domain_entities/domain_entities.dart';

/// Data model for an author.
class AuthorModel {
  final String id;
  final List<AuthorIdPair> businessIds;
  final String name;
  final String? biography;

  const AuthorModel({
    required this.id,
    required this.businessIds,
    required this.name,
    this.biography,
  });

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'businessIds': businessIds
        .map((p) => {'idType': p.idType.name, 'idCode': p.idCode})
        .toList(),
    'name': name,
    'biography': biography,
  };

  Author toEntity() =>
      Author(id: id, businessIds: businessIds, name: name, biography: biography);

  factory AuthorModel.fromEntity(Author author) => AuthorModel(
    id: author.id,
    businessIds: author.businessIds,
    name: author.name,
    biography: author.biography,
  );

  AuthorModel copyWith({
    String? id,
    List<AuthorIdPair>? businessIds,
    String? name,
    String? biography,
  }) => AuthorModel(
    id: id ?? this.id,
    businessIds: businessIds ?? this.businessIds,
    name: name ?? this.name,
    biography: biography ?? this.biography,
  );
}
