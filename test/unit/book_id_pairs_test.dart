import 'package:test/test.dart' show test, expect, group, setUp, isNot, Timeout;
import 'package:library_scanner_domain/src/domain/value_objects/book_id_pair.dart';
import 'package:library_scanner_domain/src/domain/value_objects/book_id_pairs.dart';
import 'package:library_scanner_domain/src/domain/value_objects/book_id_type.dart';

void main() {
  group('BookIdPairs Tests', () {
    late BookIdPair validIsbnPair;
    late BookIdPair validAsinPair;
    late BookIdPair validLocalPair;

    setUp(() {
      validIsbnPair = const BookIdPair(
        idType: BookIdType.isbn,
        idCode: '0306406152',
      );
      validAsinPair = const BookIdPair(
        idType: BookIdType.asin,
        idCode: 'B000000000',
      );
      validLocalPair = const BookIdPair(
        idType: BookIdType.local,
        idCode: 'local-12345',
      );
    });

    group('constructor and factory', () {
      test(
        'creates BookIdPairs with given pairs',
        () {
          final pairs = [validIsbnPair, validAsinPair, validLocalPair];
          final bookIdPairs = BookIdPairs(pairs: pairs);

          expect(bookIdPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'fromPairs factory creates BookIdPairs',
        () {
          final pairs = [validIsbnPair];
          final bookIdPairs = BookIdPairs.fromPairs('test-id', pairs);

          expect(bookIdPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('add method', () {
      test(
        'adds a new pair to the collection',
        () {
          final initialPairs = [validIsbnPair];
          final bookIdPairs = BookIdPairs(pairs: initialPairs);

          final newPairs = bookIdPairs.add(pair: validAsinPair);

          expect(newPairs.idPairs, [validIsbnPair, validAsinPair]);
          expect(bookIdPairs.idPairs, [validIsbnPair]); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'does not add duplicate pair to the collection',
        () {
          final initialPairs = [validIsbnPair];
          final bookIdPairs = BookIdPairs(pairs: initialPairs);

          final newPairs = bookIdPairs.add(pair: validIsbnPair);

          expect(newPairs.idPairs, [validIsbnPair]);
          expect(bookIdPairs.idPairs, [validIsbnPair]); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('remove method', () {
      test(
        'removes an existing pair from the collection',
        () {
          final pairs = [validIsbnPair, validAsinPair];
          final bookIdPairs = BookIdPairs(pairs: pairs);

          final newPairs = bookIdPairs.remove(pair: validIsbnPair);

          expect(newPairs.idPairs, [validAsinPair]);
          expect(bookIdPairs.idPairs, pairs); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'does not change collection when removing non-existent pair',
        () {
          final pairs = [validIsbnPair];
          final bookIdPairs = BookIdPairs(pairs: pairs);

          final newPairs = bookIdPairs.remove(pair: validAsinPair);

          expect(newPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('isEmpty and isNotEmpty getters', () {
      test(
        'isEmpty returns true for empty collection',
        () {
          final bookIdPairs = BookIdPairs(pairs: []);

          expect(bookIdPairs.isEmpty, true);
          expect(bookIdPairs.isNotEmpty, false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'isNotEmpty returns true for non-empty collection',
        () {
          final pairs = [validIsbnPair];
          final bookIdPairs = BookIdPairs(pairs: pairs);

          expect(bookIdPairs.isEmpty, false);
          expect(bookIdPairs.isNotEmpty, true);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('Equatable props', () {
      test(
        'two BookIdPairs with same pairs are equal',
        () {
          final pairs1 = [validIsbnPair, validAsinPair];
          final pairs2 = [validIsbnPair, validAsinPair];

          final bookIdPairs1 = BookIdPairs(pairs: pairs1);
          final bookIdPairs2 = BookIdPairs(pairs: pairs2);

          expect(bookIdPairs1, bookIdPairs2);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'two BookIdPairs with different pairs are not equal',
        () {
          final pairs1 = [validIsbnPair];
          final pairs2 = [validAsinPair];

          final bookIdPairs1 = BookIdPairs(pairs: pairs1);
          final bookIdPairs2 = BookIdPairs(pairs: pairs2);

          expect(bookIdPairs1, isNot(bookIdPairs2));
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });
  });
}
