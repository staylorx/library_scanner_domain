import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';

import 'book_id_pair.dart';

/// A collection of [BookIdPair] instances that uniquely identifies a book.
class BookIdPairs extends IdPairSet<BookIdPair> with EquatableMixin {
  BookIdPairs({required Iterable<BookIdPair> pairs}) : super(pairs.toList());

  factory BookIdPairs.fromPairs(String id, Iterable<BookIdPair> pairs) {
    return BookIdPairs(pairs: pairs);
  }

  BookIdPairs add({required BookIdPair pair}) {
    return BookIdPairs(pairs: [...idPairs, pair]);
  }

  BookIdPairs remove({required BookIdPair pair}) {
    return BookIdPairs(pairs: idPairs.where((p) => p != pair));
  }

  bool get isEmpty => idPairs.isEmpty;

  bool get isNotEmpty => idPairs.isNotEmpty;

  @override
  List<Object?> get props => [idPairs];
}
