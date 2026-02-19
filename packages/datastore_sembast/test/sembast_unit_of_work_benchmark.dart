import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:datastore_sembast/src/sembast/datasources/sembast_database.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SembastUnitOfWorkBenchmark extends BenchmarkBase {
  SembastUnitOfWorkBenchmark() : super('SembastUnitOfWork.run');

  late SembastDatabase database;
  late SembastUnitOfWork unitOfWork;
  late BookRepository bookRepository;
  late AuthorRepository authorRepository;
  late TagRepository tagRepository;
  late String dbPath;

  @override
  void setup() {
    dbPath = p.join(
      'build',
      'benchmark_uow_${DateTime.now().millisecondsSinceEpoch}',
    );
    database = SembastDatabase(testDbPath: dbPath);
    unitOfWork = SembastUnitOfWork(dbService: database);

    final authorDatasource = AuthorDatasource(dbService: database);
    final bookDatasource = BookDatasource(dbService: database);
    final tagDatasource = TagDatasource(dbService: database);
    final authorIdRegistry = AuthorIdRegistryServiceImpl();
    final bookIdRegistry = BookIdRegistryServiceImpl();

    authorRepository = AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: unitOfWork,
      idRegistryService: authorIdRegistry,
    );
    tagRepository = TagRepositoryImpl(
      tagDatasource: tagDatasource,
      unitOfWork: unitOfWork,
    );
    bookRepository = BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: bookIdRegistry,
      unitOfWork: unitOfWork,
    );
  }

  @override
  void run() {
    // Big test: Add 1000 books with authors and tags in one transaction
    unitOfWork.run<String>((txn) {
      return TaskEither.tryCatch(() async {
        final uuid = Uuid();
        for (var i = 0; i < 500; i++) {
          final author = Author(
            id: uuid.v4(),
            name: 'Author $i',
            businessIds: [
              AuthorIdPair(idType: AuthorIdType.local, idCode: 'Author $i'),
            ],
          );
          final addAuthorResult = await authorRepository
              .create(item: author, txn: txn)
              .run();
          addAuthorResult.fold((l) => throw l, (r) => null);

          final tag = Tag(id: uuid.v4(), name: 'Tag $i');
          final addTagResult = await tagRepository
              .create(item: tag, txn: txn)
              .run();
          addTagResult.fold((l) => throw l, (r) => null);

          final book = Book(
            id: uuid.v4(),
            title: 'Book $i',
            authors: [author],
            tags: [tag],
            businessIds: [
              BookIdPair(idType: BookIdType.local, idCode: 'Book $i'),
            ],
          );
          final addBookResult = await bookRepository
              .create(item: book, txn: txn)
              .run();
          addBookResult.fold((l) => throw l, (r) => null);
        }
        return 'benchmark result';
      }, (error, stackTrace) => ServiceFailure(error.toString()));
    });
  }

  @override
  void teardown() {
    database.close();
  }
}

void main() {
  SembastUnitOfWorkBenchmark().report();
}
