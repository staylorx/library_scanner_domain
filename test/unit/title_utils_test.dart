import 'package:test/test.dart' show test, expect, group, Timeout;
import 'package:library_scanner_domain/library_scanner_domain.dart';

void main() {
  group('Title Utils Tests', () {
    group('cleanBookTitle', () {
      test(
        'moves "The" to the end with comma',
        () {
          expect(
            cleanBookTitle(title: 'The Great Gatsby'),
            'Great Gatsby, The',
          );
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test('moves "A" to the end with comma', () {
        expect(
          cleanBookTitle(title: 'A Tale of Two Cities'),
          'Tale of Two Cities, A',
        );
      }, timeout: Timeout(Duration(seconds: 30)));

      test('moves "An" to the end with comma', () {
        expect(
          cleanBookTitle(title: 'An Introduction to Dart'),
          'Introduction to Dart, An',
        );
      }, timeout: Timeout(Duration(seconds: 30)));

      test(
        'handles lowercase articles by capitalizing moved article',
        () {
          expect(
            cleanBookTitle(title: 'the great gatsby'),
            'great gatsby, The',
          );
          expect(
            cleanBookTitle(title: 'a tale of two cities'),
            'tale of two cities, A',
          );
          expect(
            cleanBookTitle(title: 'an introduction to dart'),
            'introduction to dart, An',
          );
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test('handles uppercase articles', () {
        expect(cleanBookTitle(title: 'THE GREAT GATSBY'), 'GREAT GATSBY, The');
      }, timeout: Timeout(Duration(seconds: 30)));

      test(
        'returns title unchanged if no leading article',
        () {
          expect(cleanBookTitle(title: 'Great Gatsby'), 'Great Gatsby');
          expect(cleanBookTitle(title: '1984'), '1984');
          expect(cleanBookTitle(title: ''), '');
        },
        timeout: Timeout(Duration(seconds: 30)),
      );

      test(
        'handles title that is just the article',
        () {
          expect(cleanBookTitle(title: 'The'), 'The');
          expect(cleanBookTitle(title: 'A'), 'A');
          expect(cleanBookTitle(title: 'An'), 'An');
        },
        timeout: Timeout(Duration(seconds: 30)),
      );
    });
  });
}
