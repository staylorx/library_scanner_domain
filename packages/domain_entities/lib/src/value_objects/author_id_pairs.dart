import 'package:equatable/equatable.dart';
import 'package:id_registry/id_registry.dart';

import 'author_id_pair.dart';

/// A collection of author identifier pairs.
class AuthorIdPairs extends IdPairSet<AuthorIdPair> with EquatableMixin {
  AuthorIdPairs({required Iterable<AuthorIdPair> pairs})
    : super(pairs.toList());

  factory AuthorIdPairs.fromPairs(String id, Iterable<AuthorIdPair> pairs) {
    return AuthorIdPairs(pairs: pairs);
  }

  AuthorIdPairs add({required AuthorIdPair pair}) {
    return AuthorIdPairs(pairs: [...idPairs, pair]);
  }

  AuthorIdPairs remove({required AuthorIdPair pair}) {
    return AuthorIdPairs(pairs: idPairs.where((p) => p != pair));
  }

  bool get isEmpty => idPairs.isEmpty;

  bool get isNotEmpty => idPairs.isNotEmpty;

  /// The primary ID code, which is the ID code of the first pair.
  String get primaryIdCode => idPairs.first.idCode;

  @override
  List<Object?> get props => [idPairs];
}
