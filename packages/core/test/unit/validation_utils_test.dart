import 'package:test/test.dart' show test, expect, group, Timeout, fail;
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  group('ISBN Utils Tests', () {
    group('getIsbnIdType', () {
      test(
        'returns BookIdType.isbn10 for valid 10-character ISBN',
        () {
          final either = getIsbnIdType(isbn: '0306406152');
          either.fold(
            (l) => fail('Expected Right, got Left: $l'),
            (r) => expect(r, BookIdType.isbn10),
          );
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns BookIdType.isbn13 for valid 13-character ISBN',
        () {
          final either = getIsbnIdType(isbn: '9780306406157');
          either.fold(
            (l) => fail('Expected Right, got Left: $l'),
            (r) => expect(r, BookIdType.isbn13),
          );
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns ValidationFailure for string with length other than 10 or 13',
        () {
          final either1 = getIsbnIdType(isbn: '123456789');
          either1.fold(
            (l) => expect(l.message, "Invalid ISBN"),
            (r) => fail('Expected Left, got Right: $r'),
          );
          final either2 = getIsbnIdType(isbn: '12345678901234');
          either2.fold(
            (l) => expect(l.message, "Invalid ISBN"),
            (r) => fail('Expected Left, got Right: $r'),
          );
          final either3 = getIsbnIdType(isbn: '');
          either3.fold(
            (l) => expect(l.message, "Invalid ISBN"),
            (r) => fail('Expected Left, got Right: $r'),
          );
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });

    group('isValidISBN10', () {
      test('returns true for valid ISBN-10', () {
        // Example: "0306406152" (The C Programming Language)
        expect(isValidISBN10(code: '0306406152'), true);
        // Another: "048665088X"
        expect(isValidISBN10(code: '048665088X'), true);
      }, timeout: Timeout(Duration(seconds: 30)));

      test(
        'returns false for invalid ISBN-10 due to wrong length',
        () {
          expect(isValidISBN10(code: '123456789'), false);
          expect(isValidISBN10(code: '12345678901'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for ISBN-10 with invalid characters',
        () {
          expect(isValidISBN10(code: '123456789A'), false);
          expect(isValidISBN10(code: '123456789!'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for ISBN-10 with incorrect checksum',
        () {
          expect(isValidISBN10(code: '1234567890'), false); // Invalid checksum
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test('returns false for empty string', () {
        expect(isValidISBN10(code: ''), false);
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('isValidISBN13', () {
      test('returns true for valid ISBN-13', () {
        // Example: "9780306406157" (The C Programming Language)
        expect(isValidISBN13(code: '9780306406157'), true);
        // Another: "9780131103627"
        expect(isValidISBN13(code: '9780131103627'), true);
      }, timeout: Timeout(Duration(seconds: 30)));

      test(
        'returns false for invalid ISBN-13 due to wrong length',
        () {
          expect(isValidISBN13(code: '123456789012'), false);
          expect(isValidISBN13(code: '12345678901234'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for ISBN-13 with invalid characters',
        () {
          expect(isValidISBN13(code: '123456789012A'), false);
          expect(isValidISBN13(code: '123456789012!'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for ISBN-13 with incorrect checksum',
        () {
          expect(
            isValidISBN13(code: '9780306406158'),
            false,
          ); // Invalid checksum
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test('returns false for empty string', () {
        expect(isValidISBN13(code: ''), false);
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('isValidUPC', () {
      test('returns true for valid UPC', () {
        // Example: "012345678905" (valid UPC)
        expect(isValidUPC(code: '012345678905'), true);
        // Another: "036000291452"
        expect(isValidUPC(code: '036000291452'), true);
      }, timeout: Timeout(Duration(seconds: 30)));

      test(
        'returns false for invalid UPC due to wrong length',
        () {
          expect(isValidUPC(code: '12345678901'), false);
          expect(isValidUPC(code: '1234567890123'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for UPC with invalid characters',
        () {
          expect(isValidUPC(code: '12345678901A'), false);
          expect(isValidUPC(code: '12345678901!'), false);
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'returns false for UPC with incorrect checksum',
        () {
          expect(isValidUPC(code: '012345678906'), false); // Invalid checksum
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test('returns false for empty string', () {
        expect(isValidUPC(code: ''), false);
      }, timeout: Timeout(Duration(seconds: 30)));
    });
  });
}
