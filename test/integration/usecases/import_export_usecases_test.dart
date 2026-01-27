import 'dart:io';

import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/core/repositories/author_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/book_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/tag_repository_impl.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/author_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/book_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/tag_datasource.dart';
import 'package:library_scanner_domain/src/data/id_registry/services/author_id_registry_service.dart';
import 'package:library_scanner_domain/src/data/id_registry/services/book_id_registry_service.dart';
import 'package:library_scanner_domain/src/data/file/library_file_loader_impl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// No-op registry implementations to avoid global state collisions in tests
class _NoopAuthorRegistry implements AuthorIdRegistryService {
  @override
  TaskEither<Failure, String> generateId(String idType) => TaskEither.right('');

  @override
  TaskEither<Failure, String> generateLocalId() => TaskEither.right('');

  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<AuthorIdPairs> authorIdPairsList,
  ) => TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> registerAuthorIdPairs(AuthorIdPairs idPairs) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> unregisterAuthorIdPairs(AuthorIdPairs idPairs) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, bool> isRegistered(String idType, String idCode) =>
      TaskEither.right(false);
}

class _NoopBookRegistry implements BookIdRegistryService {
  @override
  TaskEither<Failure, String> generateId(String idType) => TaskEither.right('');

  @override
  TaskEither<Failure, String> generateLocalId() => TaskEither.right('');

  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<BookIdPairs> bookIdPairsList,
  ) => TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> registerBookIdPairs(BookIdPairs idPairs) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, Unit> unregisterBookIdPairs(BookIdPairs idPairs) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, bool> isRegistered(String idType, String idCode) =>
      TaskEither.right(false);
}

void main() {
  late SembastDatabase database;
  late SembastUnitOfWork unitOfWork;
  late AuthorDatasource authorDatasource;
  late BookDatasource bookDatasource;
  late TagDatasource tagDatasource;
  late AuthorRepositoryImpl authorRepository;
  late BookRepositoryImpl bookRepository;
  late TagRepositoryImpl tagRepository;
  late AuthorIdRegistryServiceImpl authorIdRegistryService;
  late BookIdRegistryServiceImpl bookIdRegistryService;

  setUp(() async {
    final dbPath = p.join('build', 'import_export_test_${const Uuid().v4()}');
    database = SembastDatabase(testDbPath: dbPath);
    unitOfWork = SembastUnitOfWork(dbService: database);

    authorDatasource = AuthorDatasource(dbService: database);
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);

    authorIdRegistryService = AuthorIdRegistryServiceImpl();
    bookIdRegistryService = BookIdRegistryServiceImpl();

    authorRepository = AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: unitOfWork,
      idRegistryService: _NoopAuthorRegistry(),
    );

    tagRepository = TagRepositoryImpl(
      tagDatasource: tagDatasource,
      unitOfWork: unitOfWork,
    );

    bookRepository = BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: _NoopBookRegistry(),
      unitOfWork: unitOfWork,
    );

    // Ensure DB is clean
    final clear = await database.clearAll().run();
    clear.fold((l) => throw l, (r) => null);
  });

  tearDown(() async {
    await database.close().run();
  });

  test(
    'Export writes file and Import reads it into database',
    () async {
      final dataAccess = LibraryDataAccess(
        unitOfWork: unitOfWork,
        databaseService: database,
        authorRepository: authorRepository,
        bookRepository: bookRepository,
        tagRepository: tagRepository,
        authorIdRegistryService: authorIdRegistryService,
        bookIdRegistryService: bookIdRegistryService,
      );

      // Prepare some data
      final authorLocalId = const Uuid().v4();
      final author = Author(
        id: const Uuid().v4(),
        businessIds: [
          AuthorIdPair(idType: AuthorIdType.local, idCode: authorLocalId),
        ],
        name: 'Export Author',
      );

      final tag = Tag(
        id: const Uuid().v4(),
        name: 'Export Tag',
        color: '#FF0000',
      );

      final bookLocalId = const Uuid().v4();
      final book = Book(
        id: const Uuid().v4(),
        businessIds: [
          BookIdPair(idType: BookIdType.local, idCode: bookLocalId),
        ],
        title: 'Export Book',
        originalTitle: 'Export Book',
        authors: [author],
        tags: [tag],
      );

      // Save via repositories (which will use unitOfWork)
      final aRes = await authorRepository.addAuthor(author: author).run();
      aRes.fold((l) => throw l, (r) => null);
      final tRes = await tagRepository.addTag(tag: tag).run();
      tRes.fold((l) => throw l, (r) => null);
      final bRes = await bookRepository.addBook(book: book).run();
      bRes.fold((l) => throw l, (r) => null);

      // Export
      final exportPath = p.join('build', 'export_test.yaml');
      final exportUsecase = ExportLibraryUsecase(
        dataAccess: dataAccess,
        fileLoader: LibraryFileLoaderImpl(),
      );
      final exportResult = await exportUsecase(filePath: exportPath).run();
      expect(exportResult.isRight(), true);

      // File should exist under build/
      final file = File(exportPath);
      expect(await file.exists(), true);
      final contents = await file.readAsString();
      expect(contents.contains('Export Book'), true);
      expect(contents.contains('Export Author'), true);

      // Clear DB and import from file
      final clearDb = await database.clearAll().run();
      clearDb.fold((l) => throw l, (r) => null);

      final isBookDuplicateUsecase = IsBookDuplicateUsecase();
      final importUsecase = ImportLibraryUsecase(
        dataAccess: dataAccess,
        isBookDuplicateUsecase: isBookDuplicateUsecase,
        fileLoader: LibraryFileLoaderImpl(),
      );

      final importResultEither = await importUsecase(
        filePath: exportPath,
        overwrite: false,
      ).run();
      expect(importResultEither.isRight(), true);
      final importResult = importResultEither.fold((l) => null, (r) => r)!;
      expect(importResult.parseErrors.isEmpty, true);

      // Verify DB has the imported book
      final booksAfter = await bookRepository.getBooks().run();
      expect(booksAfter.isRight(), true);
      final books = booksAfter.fold((l) => <Book>[], (r) => r);
      expect(books.any((b) => b.title == 'Export Book'), true);

      // Clean up export file
      if (await file.exists()) {
        await file.delete();
      }
    },
    timeout: Timeout(Duration(seconds: 60)),
  );
}
