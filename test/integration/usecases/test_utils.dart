import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/author_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/book_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/tag_datasource.dart';
import 'package:library_scanner_domain/src/data/core/repositories/author_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/book_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/tag_repository_impl.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class TestEnv {
  final SembastDatabase database;
  final SembastUnitOfWork unitOfWork;
  final AuthorRepositoryImpl authorRepository;
  final TagRepositoryImpl tagRepository;
  final BookRepositoryImpl bookRepository;

  TestEnv._({
    required this.database,
    required this.unitOfWork,
    required this.authorRepository,
    required this.tagRepository,
    required this.bookRepository,
  });

  static Future<TestEnv> create() async {
    final database = SembastDatabase(); // in-memory
    final unitOfWork = SembastUnitOfWork(dbService: database);

    final authorDatasource = AuthorDatasource(dbService: database);
    final tagDatasource = TagDatasource(dbService: database);
    final bookDatasource = BookDatasource(dbService: database);

    final authorRepo = AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: unitOfWork,
      idRegistryService: NoopAuthorRegistry(),
    );

    final tagRepo = TagRepositoryImpl(
      tagDatasource: tagDatasource,
      unitOfWork: unitOfWork,
    );

    final bookRepo = BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: NoopBookRegistry(),
      unitOfWork: unitOfWork,
    );

    await database.clearAll().run();

    return TestEnv._(
      database: database,
      unitOfWork: unitOfWork,
      authorRepository: authorRepo,
      tagRepository: tagRepo,
      bookRepository: bookRepo,
    );
  }

  Future<void> dispose() async {
    await database.close().run();
  }

  Future<Author> addAuthor(String name) async {
    final usecase = AddAuthorUsecase(
      authorRepository: authorRepository,
      idRegistryService: NoopAuthorRegistry(),
    );
    final res = await usecase(name: name).run();
    return res.fold((l) => throw StateError('Add author failed'), (r) => r);
  }

  Future<Tag> addTag(String name) async {
    final usecase = AddTagUsecase(
      tagRepository: tagRepository,
      getTagByNameUsecase: GetTagByNameUsecase(tagRepository: tagRepository),
    );
    final res = await usecase(name: name).run();
    return res.fold((l) => throw StateError('Add tag failed'), (r) => r);
  }

  Future<Book> addBook({
    required String title,
    required List<Author> authors,
    required List<Tag> tags,
  }) async {
    final usecase = AddBookUsecase(
      bookRepository: bookRepository,
      isBookDuplicateUsecase: IsBookDuplicateUsecase(),
    );
    final res = await usecase(
      title: title,
      authors: authors,
      tags: tags,
      publishedDate: DateTime(2024, 1, 1),
      businessIds: [
        BookIdPair(idType: BookIdType.local, idCode: const Uuid().v4()),
      ],
    ).run();
    return res.fold((l) => throw StateError('Add book failed'), (r) => r);
  }
}

// Simple noop registries used only in tests
class NoopAuthorRegistry implements AuthorIdRegistryService {
  @override
  TaskEither<Failure, String> generateId(String idType) => TaskEither.right('');
  @override
  TaskEither<Failure, String> generateLocalId() => TaskEither.right('');
  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<AuthorIdPairs> list,
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

class NoopBookRegistry implements BookIdRegistryService {
  @override
  TaskEither<Failure, String> generateId(String idType) => TaskEither.right('');
  @override
  TaskEither<Failure, String> generateLocalId() => TaskEither.right('');
  @override
  TaskEither<Failure, Unit> initializeWithExistingData(
    List<BookIdPairs> list,
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
