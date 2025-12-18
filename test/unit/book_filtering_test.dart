import 'package:test/test.dart';
import 'package:id_pair_set/id_pair_set.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Extracted filtering logic from BookListScreen for testing
List<Book> filterBooks(
  List<Book> books,
  List<Tag> tags,
  List<String> selectedTagIds,
  bool isInclusive,
  String searchQuery,
) {
  return books.where((book) {
    // Search filter
    if (searchQuery.isNotEmpty) {
      final titleMatch = book.title.toLowerCase().contains(searchQuery);
      final idPairsMatch = book.idPairs.idPairs.any(
        (pair) => pair.idCode.toLowerCase().contains(searchQuery),
      );
      final authorMatch = book.authors.any(
        (author) => author.name.toLowerCase().contains(searchQuery),
      );

      if (!titleMatch && !idPairsMatch && !authorMatch) {
        return false;
      }
    }
    // Tag filter
    if (selectedTagIds.isNotEmpty) {
      if (isInclusive) {
        // Inclusive (AND) logic: Book must have ALL selected tags
        return selectedTagIds.every(
          (selectedTagId) =>
              book.tags.any((bookTag) => bookTag.name == selectedTagId),
        );
      } else {
        // Exclusive (OR) logic: Book must have ANY of the selected tags
        return book.tags.any(
          (bookTag) => selectedTagIds.contains(bookTag.name),
        );
      }
    }
    return true;
  }).toList();
}

void main() {
  group('Book Filtering Logic Tests', () {
    late List<Book> testBooks;
    late List<Tag> testTags;

    setUp(() {
      // Create test tags
      testTags = [
        Tag(name: 'fiction', color: '#FF0000'),
        Tag(name: 'science fiction', color: '#00FF00'),
        Tag(name: 'mystery', color: '#0000FF'),
        Tag(name: 'romance', color: '#FFFF00'),
      ];

      // Create test books
      testBooks = [
        Book(
          idPairs: IdPairSet([
            BookIdPair(idType: BookIdType.local, idCode: '1'),
          ]),
          title: 'Dune',
          authors: [], // Simplified for test
          tags: [testTags[0], testTags[1]], // Fiction, Science Fiction
        ),
        Book(
          idPairs: IdPairSet([
            BookIdPair(idType: BookIdType.local, idCode: '2'),
          ]),
          title: 'The Hobbit',
          authors: [],
          tags: [testTags[0]], // Fiction
        ),
        Book(
          idPairs: IdPairSet([
            BookIdPair(idType: BookIdType.local, idCode: '3'),
          ]),
          title: 'Sherlock Holmes',
          authors: [],
          tags: [testTags[2]], // Mystery
        ),
        Book(
          idPairs: IdPairSet([
            BookIdPair(idType: BookIdType.local, idCode: '4'),
          ]),
          title: 'Pride and Prejudice',
          authors: [],
          tags: [testTags[0], testTags[3]], // Fiction, Romance
        ),
      ];
    });

    test('No filters should return all books', () {
      final result = filterBooks(testBooks, testTags, [], false, '');
      expect(result.length, 4);
    });

    test('Search filter should match title', () {
      final result = filterBooks(testBooks, testTags, [], false, 'dune');
      expect(result.length, 1);
      expect(result.first.title, 'Dune');
    });

    test('Search filter should match ID', () {
      final result = filterBooks(testBooks, testTags, [], false, '2');
      expect(result.length, 1);
      expect(result.first.title, 'The Hobbit');
    });

    test(
      'Exclusive tag filter (OR) with single tag should return matching books',
      () {
        final result = filterBooks(testBooks, testTags, ['fiction'], false, '');
        expect(result.length, 3); // Dune, Hobbit, Pride and Prejudice
        expect(result.map((b) => b.title), contains('Dune'));
        expect(result.map((b) => b.title), contains('The Hobbit'));
        expect(result.map((b) => b.title), contains('Pride and Prejudice'));
      },
    );

    test(
      'Exclusive tag filter (OR) with multiple tags should return books with any tag',
      () {
        final result = filterBooks(
          testBooks,
          testTags,
          ['fiction', 'mystery'],
          false,
          '',
        );
        expect(result.length, 4); // All books have Fiction or Mystery
      },
    );

    test(
      'Inclusive tag filter (AND) with single tag should return matching books',
      () {
        final result = filterBooks(testBooks, testTags, ['fiction'], true, '');
        expect(result.length, 3); // Same as exclusive for single tag
      },
    );

    test(
      'Inclusive tag filter (AND) with multiple tags should return books with all tags',
      () {
        final result = filterBooks(
          testBooks,
          testTags,
          ['fiction', 'science fiction'],
          true,
          '',
        );
        expect(
          result.length,
          1,
        ); // Only Dune has both Fiction and Science Fiction
        expect(result.first.title, 'Dune');
      },
    );

    test(
      'Inclusive tag filter with non-matching combination should return no books',
      () {
        final result = filterBooks(
          testBooks,
          testTags,
          ['science fiction', 'mystery'],
          true,
          '',
        );
        expect(result.length, 0); // No book has both
      },
    );

    test('Combined search and tag filter should work together', () {
      // Search for "The" and filter by Fiction tag exclusively
      final result = filterBooks(
        testBooks,
        testTags,
        ['fiction'],
        false,
        'the',
      );
      expect(result.length, 1);
      expect(result.first.title, 'The Hobbit');
    });
  });
}
