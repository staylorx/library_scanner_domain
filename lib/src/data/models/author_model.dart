import '../../domain/entities/author.dart';
import '../../domain/value_objects/author_id_pair.dart';
import '../../domain/value_objects/author_id_pairs.dart';
import '../../domain/value_objects/author_id_type.dart';
import 'package:uuid/uuid.dart';

/// A data model representing an author with their metadata and identifiers.
class AuthorModel {
  /// The unique identifier for the author, if assigned.
  final String? id;

  /// The list of identifier pairs for the author.
  final List<AuthorIdPair> idPairs;

  /// The name of the author.
  final String name;

  /// The biography of the author.
  final String? biography;

  /// The list of book identifiers associated with the author.
  final List<String> bookIdPairs;

  /// Creates an [AuthorModel] instance.
  const AuthorModel({
    this.id,
    required this.idPairs,
    required this.name,
    this.biography,
    required this.bookIdPairs,
  });

  /// Creates an [AuthorModel] from a map representation.
  factory AuthorModel.fromMap({required Map<String, dynamic> map}) {
    final idPairsList =
        (map['idPairs'] as List<dynamic>?)
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
      id: map['id'] as String?,
      idPairs: idPairsList,
      name: map['name'] as String,
      biography: map['biography'] as String?,
      bookIdPairs: (map['bookIdPairs'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts this [AuthorModel] to a map representation.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'idPairs': idPairs
          .map((p) => {'idType': p.idType.name, 'idCode': p.idCode})
          .toList(),
      'name': name,
      'biography': biography,
      'bookIdPairs': bookIdPairs,
    };
  }

  /// Converts this [AuthorModel] to an [Author] domain entity.
  Author toEntity() {
    return Author(
      idPairs: AuthorIdPairs(idPairs),
      name: name,
      biography: biography,
    );
  }

  /// Creates an [AuthorModel] from an [Author] domain entity.
  factory AuthorModel.fromEntity(Author author) {
    /// Ensure author always has at least one AuthorIdPair
    final effectiveIdPairs = author.idPairs.idPairs.isNotEmpty
        ? author.idPairs.idPairs
        : [AuthorIdPair(idType: AuthorIdType.local, idCode: const Uuid().v4())];

    return AuthorModel(
      id: author.key,
      idPairs: effectiveIdPairs,
      name: author.name,
      biography: author.biography,
      bookIdPairs: [],
    );
  }

  /// Creates a copy of this [AuthorModel] with optional field updates.
  AuthorModel copyWith({
    String? id,
    List<AuthorIdPair>? idPairs,
    String? name,
    String? biography,
    List<String>? bookIdPairs,
  }) {
    return AuthorModel(
      id: id ?? this.id,
      idPairs: idPairs ?? this.idPairs,
      name: name ?? this.name,
      biography: biography ?? this.biography,
      bookIdPairs: bookIdPairs ?? this.bookIdPairs,
    );
  }
}
