import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'author_id.dart';

/// A domain entity representing an author.
class Author with EquatableMixin {
  /// The set of identifier pairs for the author.
  final IdPairSet<AuthorIdPair> _idPairs;

  /// The name of the author.
  final String name;

  /// The biography of the author.
  final String? biography;

  /// Creates an [Author] instance.
  Author({
    required IdPairSet<AuthorIdPair> idPairs,
    required this.name,
    this.biography,
  }) : _idPairs = idPairs;

  /// The set of identifier pairs for the author.
  IdPairSet<AuthorIdPair> get idPairs => _idPairs;

  /// The key for the author, which is the name.
  String get key => name;

  /// Creates a copy of this [Author] with optional field updates.
  Author copyWith({
    IdPairSet<AuthorIdPair>? idPairs,
    String? name,
    String? biography,
  }) {
    return Author(
      idPairs: idPairs ?? this.idPairs,
      name: name ?? this.name,
      biography: biography ?? this.biography,
    );
  }

  @override
  List<Object?> get props => [idPairs, name, biography];
}
