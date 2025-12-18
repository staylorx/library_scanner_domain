import 'package:equatable/equatable.dart';

import '../value_objects/author_id_pairs.dart';

/// A domain entity representing an author.
class Author with EquatableMixin {
  /// The set of identifier pairs for the author.
  final AuthorIdPairs _idPairs;

  /// The name of the author.
  final String name;

  /// The biography of the author.
  final String? biography;

  /// Creates an [Author] instance.
  Author({required AuthorIdPairs idPairs, required this.name, this.biography})
    : _idPairs = idPairs;

  /// The set of identifier pairs for the author.
  AuthorIdPairs get idPairs => _idPairs;

  /// The key for the author, which is the idCode.
  String get key => idPairs.primaryIdCode;

  /// Creates a copy of this [Author] with optional field updates.
  Author copyWith({AuthorIdPairs? idPairs, String? name, String? biography}) {
    return Author(
      idPairs: idPairs ?? this.idPairs,
      name: name ?? this.name,
      biography: biography ?? this.biography,
    );
  }

  @override
  List<Object?> get props => [idPairs, name, biography];
}
