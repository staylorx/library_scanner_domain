import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'author_id.dart';

class Author with EquatableMixin {
  final IdPairSet<AuthorIdPair> _idPairs;
  final String name;
  final String? biography;

  Author({
    required IdPairSet<AuthorIdPair> idPairs,
    required this.name,
    this.biography,
  }) : _idPairs = idPairs;

  IdPairSet<AuthorIdPair> get idPairs => _idPairs;

  String get key => name;

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
