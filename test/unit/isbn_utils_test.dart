import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  group('ISBN Utils Tests', () {
    group('getIsbnIdType', () {
      test('returns BookIdType.isbn for 10-character string', () {
        expect(getIsbnIdType('1234567890'), BookIdType.isbn);
      });

      test('returns BookIdType.isbn13 for 13-character string', () {
        expect(getIsbnIdType('1234567890123'), BookIdType.isbn13);
      });

      test('returns null for string with length other than 10 or 13', () {
        expect(getIsbnIdType('123456789'), null);
        expect(getIsbnIdType('12345678901234'), null);
        expect(getIsbnIdType(''), null);
      });
    });

    group('isValidISBN10', () {
      test('returns true for valid ISBN-10', () {
        // Example: "0306406152" (The C Programming Language)
        expect(isValidISBN10('0306406152'), true);
        // Another: "048665088X"
        expect(isValidISBN10('048665088X'), true);
      });

      test('returns false for invalid ISBN-10 due to wrong length', () {
        expect(isValidISBN10('123456789'), false);
        expect(isValidISBN10('12345678901'), false);
      });

      test('returns false for ISBN-10 with invalid characters', () {
        expect(isValidISBN10('123456789A'), false);
        expect(isValidISBN10('123456789!'), false);
      });

      test('returns false for ISBN-10 with incorrect checksum', () {
        expect(isValidISBN10('1234567890'), false); // Invalid checksum
      });

      test('returns false for empty string', () {
        expect(isValidISBN10(''), false);
      });
    });

    group('isValidISBN13', () {
      test('returns true for valid ISBN-13', () {
        // Example: "9780306406157" (The C Programming Language)
        expect(isValidISBN13('9780306406157'), true);
        // Another: "9780131103627"
        expect(isValidISBN13('9780131103627'), true);
      });

      test('returns false for invalid ISBN-13 due to wrong length', () {
        expect(isValidISBN13('123456789012'), false);
        expect(isValidISBN13('12345678901234'), false);
      });

      test('returns false for ISBN-13 with invalid characters', () {
        expect(isValidISBN13('123456789012A'), false);
        expect(isValidISBN13('123456789012!'), false);
      });

      test('returns false for ISBN-13 with incorrect checksum', () {
        expect(isValidISBN13('9780306406158'), false); // Invalid checksum
      });

      test('returns false for empty string', () {
        expect(isValidISBN13(''), false);
      });
    });
  });
}
