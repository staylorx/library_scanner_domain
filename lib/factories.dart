import 'package:dio/dio.dart';

import 'src/data/book_api/datasources/book_api_service.dart';
import 'src/data/id_registry/services/author_id_registry_service.dart';
import 'src/data/id_registry/services/book_id_registry_service.dart';
import 'src/data/sembast/datasources/sembast_database.dart';
import 'src/data/sembast/repositories/author_repository_impl.dart';
import 'src/data/sembast/repositories/book_metadata_repository_impl.dart';
import 'src/data/sembast/repositories/book_repository_impl.dart';
import 'src/data/sembast/repositories/library_repository_impl.dart';
import 'src/data/sembast/repositories/tag_repository_impl.dart';
import 'src/domain/domain.dart';

/// Factory for creating domain layer instances with data implementations.
class LibraryFactory {
  final String? dbPath;
  final AbstractBookApiService apiService;
  final AbstractImageService imageService;

  late final SembastDatabase _database;
  late final AuthorIdRegistryService _authorIdRegistry;
  late final BookIdRegistryService _bookIdRegistry;

  /// Creates a LibraryFactory with the specified database path.
  /// If dbPath is null, uses in-memory database.
  LibraryFactory(
    this.dbPath, {
    required this.apiService,
    required this.imageService,
  }) {
    _database = SembastDatabase(testDbPath: dbPath);
    _authorIdRegistry = AuthorIdRegistryService();
    _bookIdRegistry = BookIdRegistryService();
  }

  /// Creates an AuthorRepository instance.
  Future<AuthorRepository> createAuthorRepository() async {
    return AuthorRepositoryImpl(
      databaseService: _database,
      idRegistryService: _authorIdRegistry,
    );
  }

  /// Creates a BookRepository instance.
  Future<BookRepository> createBookRepository() async {
    return BookRepositoryImpl(
      database: _database,
      idRegistryService: _bookIdRegistry,
    );
  }

  /// Creates a BookMetadataRepository instance.
  Future<BookMetadataRepository> createBookMetadataRepository() async {
    return BookMetadataRepositoryImpl(
      apiService: apiService,
      imageService: imageService,
    );
  }

  /// Creates a LibraryRepository instance.
  Future<LibraryRepository> createLibraryRepository() async {
    return LibraryRepositoryImpl(
      database: _database,
      isBookDuplicateUsecase: IsBookDuplicateUsecase(),
    );
  }

  /// Creates a TagRepository instance.
  Future<TagRepository> createTagRepository() async {
    return TagRepositoryImpl(databaseService: _database);
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _database.close();
  }
}

/// Factory for creating BookApiService.
class BookApiServiceFactory {
  /// Creates a BookApiService instance with the provided Dio client.
  AbstractBookApiService createBookApiService(Dio dio) {
    return BookApiService(dio: dio);
  }
}
