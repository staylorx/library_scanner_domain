import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  group('Title Utils Tests', () {
    group('cleanBookTitle', () {
      test('moves "The" to the end with comma', () {
        expect(cleanBookTitle('The Great Gatsby'), 'Great Gatsby, The');
      });

      test('moves "A" to the end with comma', () {
        expect(cleanBookTitle('A Tale of Two Cities'), 'Tale of Two Cities, A');
      });

      test('moves "An" to the end with comma', () {
        expect(
          cleanBookTitle('An Introduction to Dart'),
          'Introduction to Dart, An',
        );
      });

      test('handles lowercase articles by capitalizing moved article', () {
        expect(cleanBookTitle('the great gatsby'), 'great gatsby, The');
        expect(cleanBookTitle('a tale of two cities'), 'tale of two cities, A');
        expect(
          cleanBookTitle('an introduction to dart'),
          'introduction to dart, An',
        );
      });

      test('handles uppercase articles', () {
        expect(cleanBookTitle('THE GREAT GATSBY'), 'GREAT GATSBY, The');
      });

      test('returns title unchanged if no leading article', () {
        expect(cleanBookTitle('Great Gatsby'), 'Great Gatsby');
        expect(cleanBookTitle('1984'), '1984');
        expect(cleanBookTitle(''), '');
      });

      test('handles title that is just the article', () {
        expect(cleanBookTitle('The'), 'The');
        expect(cleanBookTitle('A'), 'A');
        expect(cleanBookTitle('An'), 'An');
      });
    });
  });
}
