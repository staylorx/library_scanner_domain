import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Mocks for external dependencies
class MockDatabaseService extends Mock implements DatabaseService {}

class MockUnitOfWork extends Mock implements UnitOfWork {}

void main() {
  late ProviderContainer container;
  late MockDatabaseService mockDatabaseService;
  late MockUnitOfWork mockUnitOfWork;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockUnitOfWork = MockUnitOfWork();

    container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
        unitOfWorkProvider.overrideWithValue(mockUnitOfWork),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Providers Setup Tests', () {
    test('databaseServiceProvider provides DatabaseService instance', () {
      final dbService = container.read(databaseServiceProvider);
      expect(dbService, isA<DatabaseService>());
      expect(dbService, equals(mockDatabaseService));
    });

    test('unitOfWorkProvider provides UnitOfWork instance', () {
      final unitOfWork = container.read(unitOfWorkProvider);
      expect(unitOfWork, isA<UnitOfWork>());
      expect(unitOfWork, equals(mockUnitOfWork));
    });

    test(
      'authorIdRegistryServiceProvider provides AuthorIdRegistryService instance',
      () {
        final service = container.read(authorIdRegistryServiceProvider);
        expect(service, isA<AuthorIdRegistryService>());
      },
    );

    test(
      'bookIdRegistryServiceProvider provides BookIdRegistryService instance',
      () {
        final service = container.read(bookIdRegistryServiceProvider);
        expect(service, isA<BookIdRegistryService>());
      },
    );

    test('authorDatasourceProvider provides datasource instance', () {
      final datasource = container.read(authorDatasourceProvider);
      expect(datasource, isNotNull);
    });

    test('bookDatasourceProvider provides datasource instance', () {
      final datasource = container.read(bookDatasourceProvider);
      expect(datasource, isNotNull);
    });

    test('tagDatasourceProvider provides datasource instance', () {
      final datasource = container.read(tagDatasourceProvider);
      expect(datasource, isNotNull);
    });

    test('authorRepositoryProvider provides AuthorRepository instance', () {
      final repository = container.read(authorRepositoryProvider);
      expect(repository, isA<AuthorRepository>());
    });

    test('bookRepositoryProvider provides BookRepository instance', () {
      final repository = container.read(bookRepositoryProvider);
      expect(repository, isA<BookRepository>());
    });

    test('tagRepositoryProvider provides TagRepository instance', () {
      final repository = container.read(tagRepositoryProvider);
      expect(repository, isA<TagRepository>());
    });

    test(
      'authorFilteringServiceProvider provides AuthorFilteringService instance',
      () {
        final service = container.read(authorFilteringServiceProvider);
        expect(service, isA<AuthorFilteringService>());
      },
    );

    test(
      'authorSortingServiceProvider provides AuthorSortingService instance',
      () {
        final service = container.read(authorSortingServiceProvider);
        expect(service, isA<AuthorSortingService>());
      },
    );

    test('bookSortingServiceProvider provides BookSortingService instance', () {
      final service = container.read(bookSortingServiceProvider);
      expect(service, isA<BookSortingService>());
    });

    test(
      'bookFilteringServiceProvider provides BookFilteringService instance',
      () {
        final service = container.read(bookFilteringServiceProvider);
        expect(service, isA<BookFilteringService>());
      },
    );

    test(
      'authorValidationServiceProvider provides AuthorValidationService instance',
      () {
        final service = container.read(authorValidationServiceProvider);
        expect(service, isA<AuthorValidationService>());
      },
    );

    test(
      'bookValidationServiceProvider provides BookValidationService instance',
      () {
        final service = container.read(bookValidationServiceProvider);
        expect(service, isA<BookValidationService>());
      },
    );

    test('libraryDataAccessProvider provides LibraryDataAccess instance', () {
      final dataAccess = container.read(libraryDataAccessProvider);
      expect(dataAccess, isA<LibraryDataAccess>());
    });

    // Test a few usecase providers
    test('addAuthorUsecaseProvider provides AddAuthorUsecase instance', () {
      final usecase = container.read(addAuthorUsecaseProvider);
      expect(usecase, isA<AddAuthorUsecase>());
    });

    test('getAuthorsUsecaseProvider provides GetAuthorsUsecase instance', () {
      final usecase = container.read(getAuthorsUsecaseProvider);
      expect(usecase, isA<GetAuthorsUsecase>());
    });

    test(
      'filterAuthorsUsecaseProvider provides FilterAuthorsUsecase instance',
      () {
        final usecase = container.read(filterAuthorsUsecaseProvider);
        expect(usecase, isA<FilterAuthorsUsecase>());
      },
    );

    test(
      'getSortedAuthorsUsecaseProvider provides GetSortedAuthorsUsecase instance',
      () {
        final usecase = container.read(getSortedAuthorsUsecaseProvider);
        expect(usecase, isA<GetSortedAuthorsUsecase>());
      },
    );
  });

  group('transactionProvider Tests', () {
    test(
      'transactionProvider throws UnimplementedError when not overridden',
      () {
        final container = ProviderContainer(); // no overrides
        expect(
          () => container.read(transactionProvider),
          throwsA(
            predicate((e) => e.toString().contains('UnimplementedError')),
          ),
        );
        container.dispose();
      },
    );

    test(
      'transactionProvider provides UnitOfWork instance when overridden',
      () {
        final container = ProviderContainer(
          overrides: [transactionProvider.overrideWithValue(mockUnitOfWork)],
        );
        final unitOfWork = container.read(transactionProvider);
        expect(unitOfWork, isA<UnitOfWork>());
        expect(unitOfWork, equals(mockUnitOfWork));
        container.dispose();
      },
    );
  });
}
