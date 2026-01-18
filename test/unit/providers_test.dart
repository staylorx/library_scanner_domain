import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// Mocks for external dependencies
class MockDio extends Mock implements Dio {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockUnitOfWork extends Mock implements UnitOfWork {}

class MockImageService extends Mock implements ImageService {}

void main() {
  late ProviderContainer container;
  late MockDio mockDio;
  late MockDatabaseService mockDatabaseService;
  late MockUnitOfWork mockUnitOfWork;
  late MockImageService mockImageService;

  setUp(() {
    mockDio = MockDio();
    mockDatabaseService = MockDatabaseService();
    mockUnitOfWork = MockUnitOfWork();
    mockImageService = MockImageService();

    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
        unitOfWorkProvider.overrideWithValue(mockUnitOfWork),
        imageServiceProvider.overrideWithValue(mockImageService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Providers Setup Tests', () {
    test('dioProvider provides Dio instance', () {
      final dio = container.read(dioProvider);
      expect(dio, isA<Dio>());
      expect(dio, equals(mockDio));
    });

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

    test('imageServiceProvider provides ImageService instance', () {
      final imageService = container.read(imageServiceProvider);
      expect(imageService, isA<ImageService>());
      expect(imageService, equals(mockImageService));
    });

    test('bookApiServiceProvider provides BookApiService instance', () {
      final apiService = container.read(bookApiServiceProvider);
      expect(apiService, isA<BookApiService>());
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

    test(
      'bookMetadataRepositoryProvider provides BookMetadataRepository instance',
      () {
        final repository = container.read(bookMetadataRepositoryProvider);
        expect(repository, isA<BookMetadataRepository>());
      },
    );

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
}
