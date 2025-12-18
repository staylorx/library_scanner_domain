import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';

import 'author_id_pair.dart';

// AuthorIdPairs is a collection of AuthorIdPairs that uniquely identifies a Author
class AuthorIdPairs extends IdPairSet<AuthorIdPair> with EquatableMixin {
  AuthorIdPairs(Iterable<AuthorIdPair> pairs) : super(pairs.toList());

  factory AuthorIdPairs.fromPairs(String id, Iterable<AuthorIdPair> pairs) {
    return AuthorIdPairs(pairs);
  }

  AuthorIdPairs add({required AuthorIdPair pair}) {
    return AuthorIdPairs([...idPairs, pair]);
  }

  AuthorIdPairs remove({required AuthorIdPair pair}) {
    return AuthorIdPairs(idPairs.where((p) => p != pair));
  }

  bool get isEmpty => idPairs.isEmpty;

  bool get isNotEmpty => idPairs.isNotEmpty;

  /// The primary ID code, which is the ID code of the first pair.
  String get primaryIdCode => idPairs.first.idCode;

  @override
  List<Object?> get props => [idPairs];
}
