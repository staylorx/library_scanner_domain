import 'package:test/test.dart'
    show test, expect, group, setUp, contains, Timeout, fail;
import 'package:domain_entities/domain_entities.dart';
import 'package:dataservice_filtering/dataservice_filtering.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Book Filtering Service Tests', () {
    late List<Book> testBooks;
    late List<Tag> testTags;
    late BookFilteringServiceImpl service;

    setUp(() {
      service = BookFilteringServiceImpl();
      // Create test tags
      testTags = [
        Tag(id: const Uuid().v4(), name: 'fiction', color: '#FF0000'),
        Tag(id: const Uuid().v4(), name: 'science fiction', color: '#00FF00'),
        Tag(id: const Uuid().v4(), name: 'mystery', color: '#0000FF'),
        Tag(id: const Uuid().v4(), name: 'romance', color: '#FFFF00'),
      ];

      // Create test books
      testBooks = [
        Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: '1')],
          title: 'Dune',
          authors: [], // Simplified for test
          tags: [testTags[0], testTags[1]], // Fiction, Science Fiction
        ),
        Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: '2')],
          title: 'The Hobbit',
          authors: [],
          tags: [testTags[0]], // Fiction
        ),
        Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: '3')],
          title: 'Sherlock Holmes',
          authors: [],
          tags: [testTags[2]], // Mystery
        ),
        Book(
          id: const Uuid().v4(),
          businessIds: [BookIdPair(idType: BookIdType.local, idCode: '4')],
          title: 'Pride and Prejudice',
          authors: [],
          tags: [testTags[0], testTags[3]], // Fiction, Romance
        ),
      ];
    });

    test('No filters should return all books', () async {
      final result = await service.filterBooks(
        books: testBooks,
        tags: testTags,
        searchQuery: '',
        selectedTagIds: [],
        isInclusiveFilter: false,
      ).run();
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (books) => expect(books.length, 4),
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test('Search filter should match title', () async {
      final result = await service.filterBooks(
        books: testBooks,
        tags: testTags,
        searchQuery: 'dune',
        selectedTagIds: [],
        isInclusiveFilter: false,
      ).run();
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (books) {
          expect(books.length, 1);
          expect(books.first.title, 'Dune');
        },
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test('Search filter should match ID', () async {
      final result = await service.filterBooks(
        books: testBooks,
        tags: testTags,
        searchQuery: '2',
        selectedTagIds: [],
        isInclusiveFilter: false,
      ).run();
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (books) {
          expect(books.length, 1);
          expect(books.first.title, 'The Hobbit');
        },
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test(
      'Exclusive tag filter (OR) with single tag should return matching books',
      () async {
        final result = await service.filterBooks(
          books: testBooks,
          tags: testTags,
          searchQuery: '',
          selectedTagIds: ['fiction'],
          isInclusiveFilter: false,
        ).run();
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (books) {
            expect(books.length, 3); // Dune, Hobbit, Pride and Prejudice
            expect(books.map((b) => b.title), contains('Dune'));
            expect(books.map((b) => b.title), contains('The Hobbit'));
            expect(books.map((b) => b.title), contains('Pride and Prejudice'));
          },
        );
      },
      timeout: Timeout(Duration(seconds: 30)),
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
      timeout: Timeout(Duration(seconds: 30)),
    );

    test(
      'Inclusive tag filter (AND) with single tag should return matching books',
      () {
        final result = filterBooks(testBooks, testTags, ['fiction'], true, '');
        expect(result.length, 3); // Same as exclusive for single tag
      },
      timeout: Timeout(Duration(seconds: 30)),
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
      timeout: Timeout(Duration(seconds: 30)),
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
      timeout: Timeout(Duration(seconds: 30)),
    );

    test(
      'Combined search and tag filter should work together',
      () {
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
      },
      timeout: Timeout(Duration(seconds: 30)),
    );
  });
}
