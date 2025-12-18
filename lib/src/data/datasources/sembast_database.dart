import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:sembast/sembast_io.dart';

class SembastDatabase implements DatabaseService {
  static const String _booksStoreName = 'books';
  static const String _authorsStoreName = 'authors';
  static const String _tagsStoreName = 'tags';

  final String? testDbPath;

  SembastDatabase({this.testDbPath});

  Database? _database;

  final StoreRef<String, Map<String, dynamic>> booksStore =
      StoreRef<String, Map<String, dynamic>>(_booksStoreName);
  final StoreRef<String, Map<String, dynamic>> authorsStore =
      StoreRef<String, Map<String, dynamic>>(_authorsStoreName);
  final StoreRef<String, Map<String, dynamic>> tagsStore =
      StoreRef<String, Map<String, dynamic>>(_tagsStoreName);

  StoreRef<String, Map<String, dynamic>> _getStore(String collection) {
    switch (collection) {
      case _booksStoreName:
        return booksStore;
      case _authorsStoreName:
        return authorsStore;
      case _tagsStoreName:
        return tagsStore;
      default:
        throw UnsupportedError('Unknown collection: $collection');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = testDbPath ?? 'test.db';
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  @override
  Future<Either<Failure, void>> save(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      await store.record(id).put(db, data);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Failed to save: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> get(
    String collection,
    String id,
  ) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      final record = await store.record(id).get(db);
      return right(record);
    } catch (e) {
      return left(DatabaseFailure('Failed to get: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll(
    String collection, {
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      final finder = Finder(limit: limit, offset: offset);
      final records = await store.find(db, finder: finder);
      return right(records.map((r) => r.value).toList());
    } catch (e) {
      return left(DatabaseFailure('Failed to get all: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> query(
    String collection,
    Map<String, dynamic> filter, {
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      Filter? queryFilter;
      if (filter.isNotEmpty) {
        final filters = <Filter>[];
        for (final entry in filter.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is Map && value.containsKey('\$in')) {
            filters.add(
              Filter.inList(key, (value['\$in'] as List).cast<Object>()),
            );
          } else {
            filters.add(Filter.equals(key, value));
          }
        }
        queryFilter = Filter.and(filters);
      }
      final finder = Finder(filter: queryFilter, limit: limit, offset: offset);
      final records = await store.find(db, finder: finder);
      return right(records.map((r) => r.value).toList());
    } catch (e) {
      return left(DatabaseFailure('Failed to query: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String collection, String id) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      await store.record(id).delete(db);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Failed to delete: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clear(String collection) async {
    try {
      final db = await database;
      final store = _getStore(collection);
      await store.delete(db);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Failed to clear: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final db = await database;
      await booksStore.delete(db);
      await authorsStore.delete(db);
      await tagsStore.delete(db);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Failed to clear all: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> transaction(Function() operation) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await operation();
      });
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Transaction failed: $e'));
    }
  }

  @override
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
