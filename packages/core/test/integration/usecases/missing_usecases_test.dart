import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/author_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/book_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/tag_datasource.dart';
import 'package:library_scanner_domain/src/data/core/repositories/author_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/book_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/tag_repository_impl.dart';
import 'package:uuid/uuid.dart';
import 'package:library_scanner_domain/src/data/core/services/author_filtering_service.dart';
import 'package:library_scanner_domain/src/data/core/services/author_sorting_service.dart';
import 'package:library_scanner_domain/src/data/core/services/book_validation_service.dart';

// No-op registry implementations to keep tests deterministic
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

  setUp(() async {
    // In-memory Sembast (no testDbPath)
    database = SembastDatabase();
    unitOfWork = SembastUnitOfWork(dbService: database);

    authorDatasource = AuthorDatasource(dbService: database);
    tagDatasource = TagDatasource(dbService: database);
    bookDatasource = BookDatasource(dbService: database);

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
    await database.clearAll().run();
  });

  tearDown(() async {
    await database.close().run();
  });

  test(
    'Remaining usecases: lookup, filter, sort, validate, duplicates',
    () async {
      final addAuthorUsecase = AddAuthorUsecase(
        authorRepository: authorRepository,
        idRegistryService: _NoopAuthorRegistry(),
      );

      final addTagUsecase = AddTagUsecase(
        tagRepository: tagRepository,
        getTagByNameUsecase: GetTagByNameUsecase(tagRepository: tagRepository),
      );

      final addBookUsecase = AddBookUsecase(
        bookRepository: bookRepository,
        isBookDuplicateUsecase: IsBookDuplicateUsecase(),
      );

      // Add authors
      final a1Res = await addAuthorUsecase(name: 'Author A').run();
      expect(a1Res.isRight(), true);
      final a2Res = await addAuthorUsecase(name: 'Author B').run();
      expect(a2Res.isRight(), true);

      // Add tag
      final tRes = await addTagUsecase(name: 'TagX').run();
      expect(tRes.isRight(), true);

      // Retrieve authors to use their id pairs
      final authorsAll = await authorRepository.getAll().run();
      expect(authorsAll.isRight(), true);
      final authors = authorsAll.getRight().getOrElse(() => <Author>[]);
      expect(authors.length, 2);
      final authorA = authors.firstWhere((a) => a.name == 'Author A');
      // authorB intentionally not used in this test

      // Add a book referencing Author A and TagX
      final tagsAll = await tagRepository.getAll().run();
      final tagX = tagsAll.getRight().getOrElse(() => <Tag>[]).first;

      final addBook = await addBookUsecase(
        title: 'Book 1',
        authors: [authorA],
        tags: [tagX],
        publishedDate: DateTime(2024, 1, 1),
        businessIds: [
          BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
        ],
      ).run();
      expect(addBook.isRight(), true);

      // Test GetAuthorsByNamesUsecase
      final getAuthorsByNamesUsecase = GetAuthorsByNamesUsecase(
        authorRepository: authorRepository,
      );
      final byNames = await getAuthorsByNamesUsecase(names: ['Author A']).run();
      expect(byNames.isRight(), true);
      final found = byNames.getRight().getOrElse(() => <Author>[]);
      expect(found.any((a) => a.name == 'Author A'), true);

      // Test GetAuthorByIdPairUsecase
      final getAuthorByIdPairUsecase = GetAuthorByIdPairUsecase(
        authorRepository: authorRepository,
      );
      final authById = await getAuthorByIdPairUsecase(
        authorIdPair: authorA.businessIds.first,
      ).run();
      expect(authById.isRight(), true);
      expect(authById.getRight().getOrElse(() => authorA).name, 'Author A');

      // Test GetTagsByNamesUsecase
      final getTagsByNamesUsecase = GetTagsByNamesUsecase(
        tagRepository: tagRepository,
      );
      final tagsByName = await getTagsByNamesUsecase(names: ['TagX']).run();
      expect(tagsByName.isRight(), true);
      expect(
        tagsByName
            .getRight()
            .getOrElse(() => <Tag>[])
            .any((t) => t.name == 'TagX'),
        true,
      );

      // Test GetBookByIdPairUsecase
      final booksAll = await bookRepository.getBooks().run();
      final book = booksAll.getRight().getOrElse(() => <Book>[]).first;
      final getBookByIdPairUsecase = GetBookByIdPairUsecase(
        bookRepository: bookRepository,
      );
      final bookById = await getBookByIdPairUsecase(
        bookIdPair: book.businessIds.first,
      ).run();
      expect(bookById.isRight(), true);
      expect(bookById.getRight().getOrElse(() => book).title, 'Book 1');

      // Test FilterAuthorsUsecase
      final filterAuthorsUsecase = FilterAuthorsUsecase(
        AuthorFilteringServiceImpl(),
      );
      final filteredAuthors = await filterAuthorsUsecase(
        authors: authors,
        searchQuery: 'Author A',
      ).run();
      expect(filteredAuthors.isRight(), true);
      expect(
        filteredAuthors
            .getRight()
            .getOrElse(() => <Author>[])
            .any((a) => a.name == 'Author A'),
        true,
      );

      // Test GetSortedAuthorsUsecase
      final getSortedAuthorsUsecase = GetSortedAuthorsUsecase(
        sortingService: AuthorSortingServiceImpl(),
      );
      final sorted = await getSortedAuthorsUsecase(
        authors,
        const AuthorSortSettings(),
      ).run();
      expect(sorted.isRight(), true);

      // Test ValidateBookUsecase (should pass with Noop registry)
      final validateBookUsecase = ValidateBookUsecase(
        bookValidationService: BookValidationServiceImpl(
          idRegistryService: _NoopBookRegistry(),
        ),
      );
      final validateRes = await validateBookUsecase(book).run();
      expect(validateRes.isRight(), true);

      // Test IsBookDuplicateUsecase and IsAuthorDuplicateUsecase
      final isBookDuplicate = IsBookDuplicateUsecase();
      final duplicateResult = isBookDuplicate(bookA: book, bookB: book);
      expect(duplicateResult.isRight(), true);
      final isDup = duplicateResult.getRight().getOrElse(() => false);
      expect(isDup, true);

      final isAuthorDuplicate = IsAuthorDuplicateUsecase();
      final authorDup = isAuthorDuplicate(authorA: authorA, authorB: authorA);
      expect(authorDup.isRight(), true);
      expect(authorDup.getRight().getOrElse(() => false), true);
    },
    timeout: Timeout(Duration(seconds: 60)),
  );
}
