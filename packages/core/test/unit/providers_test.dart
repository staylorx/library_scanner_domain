import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Mocks for external dependencies
class MockDatabaseService extends Mock implements DatabaseService {}

class MockUnitOfWork extends Mock implements UnitOfWork {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockUnitOfWork mockUnitOfWork;
  late LibraryDomain domain;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockUnitOfWork = MockUnitOfWork();

    domain = LibraryDomainFactory.create(
      databaseService: mockDatabaseService,
      unitOfWork: mockUnitOfWork,
    );
  });

  group('LibraryDomainFactory Tests', () {
    test('LibraryDomainFactory.create returns LibraryDomain instance', () {
      expect(domain, isA<LibraryDomain>());
    });

    test('LibraryDomain has addAuthorUsecase', () {
      expect(domain.addAuthorUsecase, isA<AddAuthorUsecase>());
    });

    test('LibraryDomain has deleteAuthorUsecase', () {
      expect(domain.deleteAuthorUsecase, isA<DeleteAuthorUsecase>());
    });

    test('LibraryDomain has updateAuthorUsecase', () {
      expect(domain.updateAuthorUsecase, isA<UpdateAuthorUsecase>());
    });

    test('LibraryDomain has getAuthorsUsecase', () {
      expect(domain.getAuthorsUsecase, isA<GetAuthorsUsecase>());
    });

    test('LibraryDomain has getAuthorByNameUsecase', () {
      expect(domain.getAuthorByNameUsecase, isA<GetAuthorByNameUsecase>());
    });

    test('LibraryDomain has getAuthorsByNamesUsecase', () {
      expect(domain.getAuthorsByNamesUsecase, isA<GetAuthorsByNamesUsecase>());
    });

    test('LibraryDomain has getAuthorByIdPairUsecase', () {
      expect(domain.getAuthorByIdPairUsecase, isA<GetAuthorByIdPairUsecase>());
    });

    test('LibraryDomain has getSortedAuthorsUsecase', () {
      expect(domain.getSortedAuthorsUsecase, isA<GetSortedAuthorsUsecase>());
    });

    test('LibraryDomain has filterAuthorsUsecase', () {
      expect(domain.filterAuthorsUsecase, isA<FilterAuthorsUsecase>());
    });

    test('LibraryDomain has isAuthorDuplicateUsecase', () {
      expect(domain.isAuthorDuplicateUsecase, isA<IsAuthorDuplicateUsecase>());
    });

    test('LibraryDomain has addBookUsecase', () {
      expect(domain.addBookUsecase, isA<AddBookUsecase>());
    });

    test('LibraryDomain has deleteBookUsecase', () {
      expect(domain.deleteBookUsecase, isA<DeleteBookUsecase>());
    });

    test('LibraryDomain has updateBookUsecase', () {
      expect(domain.updateBookUsecase, isA<UpdateBookUsecase>());
    });

    test('LibraryDomain has getBooksUsecase', () {
      expect(domain.getBooksUsecase, isA<GetBooksUsecase>());
    });

    test('LibraryDomain has getBookByIdPairUsecase', () {
      expect(domain.getBookByIdPairUsecase, isA<GetBookByIdPairUsecase>());
    });

    test('LibraryDomain has getBooksByAuthorUsecase', () {
      expect(domain.getBooksByAuthorUsecase, isA<GetBooksByAuthorUseCase>());
    });

    test('LibraryDomain has getBooksByTagUsecase', () {
      expect(domain.getBooksByTagUsecase, isA<GetBooksByTagUseCase>());
    });

    test('LibraryDomain has getSortedBooksUsecase', () {
      expect(domain.getSortedBooksUsecase, isA<GetSortedBooksUsecase>());
    });

    test('LibraryDomain has filterBooksUsecase', () {
      expect(domain.filterBooksUsecase, isA<FilterBooksUsecase>());
    });

    test('LibraryDomain has isBookDuplicateUsecase', () {
      expect(domain.isBookDuplicateUsecase, isA<IsBookDuplicateUsecase>());
    });

    test('LibraryDomain has validateBookUsecase', () {
      expect(domain.validateBookUsecase, isA<ValidateBookUsecase>());
    });

    test('LibraryDomain has addTagUsecase', () {
      expect(domain.addTagUsecase, isA<AddTagUsecase>());
    });

    test('LibraryDomain has deleteTagUsecase', () {
      expect(domain.deleteTagUsecase, isA<DeleteTagUsecase>());
    });

    test('LibraryDomain has updateTagUsecase', () {
      expect(domain.updateTagUsecase, isA<UpdateTagUsecase>());
    });

    test('LibraryDomain has getTagsUsecase', () {
      expect(domain.getTagsUsecase, isA<GetTagsUsecase>());
    });

    test('LibraryDomain has getTagByNameUsecase', () {
      expect(domain.getTagByNameUsecase, isA<GetTagByNameUsecase>());
    });

    test('LibraryDomain has getTagsByNamesUsecase', () {
      expect(domain.getTagsByNamesUsecase, isA<GetTagsByNamesUsecase>());
    });

    test('LibraryDomain has clearLibraryUsecase', () {
      expect(domain.clearLibraryUsecase, isA<ClearLibraryUsecase>());
    });

    test('LibraryDomain has exportLibraryUsecase', () {
      expect(domain.exportLibraryUsecase, isA<ExportLibraryUsecase>());
    });

    test('LibraryDomain has importLibraryUsecase', () {
      expect(domain.importLibraryUsecase, isA<ImportLibraryUsecase>());
    });

    test('LibraryDomain has getLibraryStatsUsecase', () {
      expect(domain.getLibraryStatsUsecase, isA<GetLibraryStatsUsecase>());
    });
  });
}
