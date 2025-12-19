import 'package:test/test.dart' show test, expect, group, setUp, isNot, Timeout;
import 'package:library_scanner_domain/src/domain/value_objects/author_id_pair.dart';
import 'package:library_scanner_domain/src/domain/value_objects/author_id_pairs.dart';
import 'package:library_scanner_domain/src/domain/value_objects/author_id_type.dart';

void main() {
  group('AuthorIdPairs Tests', () {
    late AuthorIdPair validIsniPair;
    late AuthorIdPair validOrcidPair;
    late AuthorIdPair validLocalPair;
    late AuthorIdPairs author1;
    late AuthorIdPairs author2;

    setUp(() {
      validIsniPair = const AuthorIdPair(
        idType: AuthorIdType.isni,
        idCode: '0000000123456789',
      );
      validOrcidPair = const AuthorIdPair(
        idType: AuthorIdType.orcid,
        idCode: '0000-0000-0000-0000',
      );
      validLocalPair = const AuthorIdPair(
        idType: AuthorIdType.local,
        idCode: 'local-12345',
      );
      // these authors should never be equal
      author1 = AuthorIdPairs([validIsniPair, validOrcidPair]);
      author2 = AuthorIdPairs([validIsniPair, validLocalPair]);
    });

    group('constructor and factory', () {
      test(
        'creates AuthorIdPairs with given pairs',
        () {
          final pairs = [validIsniPair, validOrcidPair, validLocalPair];
          final authorIdPairs = AuthorIdPairs(pairs);

          expect(authorIdPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'fromPairs factory creates AuthorIdPairs',
        () {
          final pairs = [validIsniPair];
          final authorIdPairs = AuthorIdPairs.fromPairs('test-id', pairs);

          expect(authorIdPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('add method', () {
      test(
        'adds a new pair to the collection',
        () {
          final initialPairs = [validIsniPair];
          final authorIdPairs = AuthorIdPairs(initialPairs);

          final newPairs = authorIdPairs.add(pair: validOrcidPair);

          expect(newPairs.idPairs, [validIsniPair, validOrcidPair]);
          expect(authorIdPairs.idPairs, [validIsniPair]); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'does not add duplicate pair to the collection',
        () {
          final initialPairs = [validIsniPair];
          final authorIdPairs = AuthorIdPairs(initialPairs);

          final newPairs = authorIdPairs.add(pair: validIsniPair);

          expect(newPairs.idPairs, [validIsniPair]);
          expect(authorIdPairs.idPairs, [validIsniPair]); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('remove method', () {
      test(
        'removes an existing pair from the collection',
        () {
          final pairs = [validIsniPair, validOrcidPair];
          final authorIdPairs = AuthorIdPairs(pairs);

          final newPairs = authorIdPairs.remove(pair: validIsniPair);

          expect(newPairs.idPairs, [validOrcidPair]);
          expect(authorIdPairs.idPairs, pairs); // original unchanged
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'does not change collection when removing non-existent pair',
        () {
          final pairs = [validIsniPair];
          final authorIdPairs = AuthorIdPairs(pairs);

          final newPairs = authorIdPairs.remove(pair: validOrcidPair);

          expect(newPairs.idPairs, pairs);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('isEmpty and isNotEmpty getters', () {
      test(
        'isEmpty returns true for empty collection',
        () {
          final authorIdPairs = AuthorIdPairs([]);

          expect(authorIdPairs.isEmpty, true);
          expect(authorIdPairs.isNotEmpty, false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'isNotEmpty returns true for non-empty collection',
        () {
          final pairs = [validIsniPair];
          final authorIdPairs = AuthorIdPairs(pairs);

          expect(authorIdPairs.isEmpty, false);
          expect(authorIdPairs.isNotEmpty, true);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('Equatable props', () {
      test(
        'two AuthorIdPairs with same pairs are equal',
        () {
          final pairs1 = [validIsniPair, validOrcidPair];
          final pairs2 = [validIsniPair, validOrcidPair];

          final authorIdPairs1 = AuthorIdPairs(pairs1);
          final authorIdPairs2 = AuthorIdPairs(pairs2);

          expect(authorIdPairs1, authorIdPairs2);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'two AuthorIdPairs with different pairs are not equal',
        () {
          final pairs1 = [validIsniPair];
          final pairs2 = [validOrcidPair];

          final authorIdPairs1 = AuthorIdPairs(pairs1);
          final authorIdPairs2 = AuthorIdPairs(pairs2);

          expect(authorIdPairs1, isNot(authorIdPairs2));
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });
  });
}
