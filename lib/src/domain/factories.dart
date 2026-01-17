import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../data/book_api/datasources/book_api_service.dart';
import '../utils/failure.dart';
import '../data/id_registry/services/book_id_registry_service.dart';
import '../data/sembast/datasources/sembast_database.dart';
import '../data/sembast/repositories/author_repository_impl.dart';
import '../data/sembast/repositories/book_metadata_repository_impl.dart';
import '../data/sembast/repositories/book_repository_impl.dart';
import '../data/sembast/repositories/tag_repository_impl.dart';
import '../data/sembast/unit_of_work/sembast_unit_of_work.dart';
import '../data/storage/author_datasource.dart';
import '../data/storage/book_datasource.dart';
import '../data/storage/tag_datasource.dart';
import 'domain.dart';

/// Factory for creating domain layer instances with data implementations.
class LibraryFactory {
  final String? dbPath;
  final BookApiService apiService;
  final ImageService imageService;

  late final SembastDatabase _database;
  late final BookIdRegistryServiceImpl _bookIdRegistry;
  late final UnitOfWork _unitOfWork;
  late final BookDatasource bookDatasource;
  late final AuthorDatasource authorDatasource;
  late final TagDatasource tagDatasource;

  /// Creates a LibraryFactory with the specified database path.
  /// If dbPath is null, uses in-memory database.
  LibraryFactory(
    this.dbPath, {
    required this.apiService,
    required this.imageService,
  }) {
    _database = SembastDatabase(testDbPath: dbPath);
    _bookIdRegistry = BookIdRegistryServiceImpl();
    _unitOfWork = SembastUnitOfWork(dbService: _database);
  }

  Future<AuthorDatasource> getAuthorDatasource() async {
    authorDatasource = AuthorDatasource(dbService: _database);
    return authorDatasource;
  }

  Future<BookDatasource> getBookDatasource() async {
    bookDatasource = BookDatasource(dbService: _database);
    return bookDatasource;
  }

  Future<TagDatasource> getTagDatasource() async {
    tagDatasource = TagDatasource(dbService: _database);
    return tagDatasource;
  }

  /// Creates an AuthorRepository instance.
  Future<AuthorRepository> createAuthorRepository() async {
    final authorDatasource = AuthorDatasource(dbService: _database);
    return AuthorRepositoryImpl(
      authorDatasource: authorDatasource,
      unitOfWork: _unitOfWork,
    );
  }

  /// Creates a BookRepository instance.
  Future<BookRepository> createBookRepository() async {
    final bookDatasource = BookDatasource(dbService: _database);
    final authorDatasource = AuthorDatasource(dbService: _database);
    final tagDatasource = TagDatasource(dbService: _database);
    return BookRepositoryImpl(
      bookDatasource: bookDatasource,
      authorDatasource: authorDatasource,
      tagDatasource: tagDatasource,
      idRegistryService: _bookIdRegistry,
      unitOfWork: _unitOfWork,
    );
  }

  /// Creates a BookMetadataRepository instance.
  Future<BookMetadataRepository> createBookMetadataRepository() async {
    return BookMetadataRepositoryImpl(
      apiService: apiService,
      imageService: imageService,
    );
  }

  /// Creates a TagRepository instance.
  Future<TagRepository> createTagRepository() async {
    final tagDatasource = TagDatasource(dbService: _database);
    return TagRepositoryImpl(
      tagDatasource: tagDatasource,
      databaseService: _database,
      unitOfWork: _unitOfWork,
    );
  }

  /// Closes the database connection.
  Future<Either<Failure, Unit>> close() async {
    return _database.close();
  }
}

/// Factory for creating BookApiService.
class BookApiServiceFactory {
  /// Creates a BookApiService instance with the provided Dio client.
  BookApiService createBookApiService(Dio dio) {
    return BookApiServiceImpl(dio: dio);
  }
}
