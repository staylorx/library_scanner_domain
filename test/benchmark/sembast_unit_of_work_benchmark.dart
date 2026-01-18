import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/author_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/book_datasource.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/tag_datasource.dart';
import 'package:library_scanner_domain/src/data/core/repositories/book_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/author_repository_impl.dart';
import 'package:library_scanner_domain/src/data/core/repositories/tag_repository_impl.dart';
import 'package:library_scanner_domain/src/data/id_registry/services/author_id_registry_service.dart';
import 'package:library_scanner_domain/src/data/id_registry/services/book_id_registry_service.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SembastUnitOfWorkBenchmark extends BenchmarkBase {
  SembastUnitOfWorkBenchmark() : super('SembastUnitOfWork.run');

  late DatabaseService database;
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
    unitOfWork.run((txn) async {
      const uuid = Uuid();
      for (var i = 0; i < 500; i++) {
        final author = Author(
          id: uuid.v4(),
          name: 'Author $i',
          businessIds: [
            AuthorIdPair(idType: AuthorIdType.local, idCode: 'Author $i'),
          ],
        );
        await authorRepository.addAuthor(author: author, txn: txn);

        final tag = Tag(id: uuid.v4(), name: 'Tag $i');
        await tagRepository.addTag(tag: tag, txn: txn);

        final book = Book(
          id: uuid.v4(),
          title: 'Book $i',
          authors: [author],
          tags: [tag],
          businessIds: [
            BookIdPair(idType: BookIdType.local, idCode: 'Book $i'),
          ],
        );
        await bookRepository.addBook(book: book, txn: txn);
      }
      return 'benchmark result';
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
