import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

/// Database service using Sembast for local storage.
class SembastDatabase with Loggable implements DatabaseService {
  static const String _booksStoreName = 'books';
  static const String _authorsStoreName = 'authors';
  static const String _tagsStoreName = 'tags';

  final String? testDbPath;

  /// Creates a SembastDatabase instance.
  SembastDatabase({this.testDbPath, Logger? logger}) {
    this.logger = logger;
  }
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

  /// Gets the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if (testDbPath == null) {
      return await databaseFactoryMemory.openDatabase('');
    } else {
      return await databaseFactoryIo.openDatabase(testDbPath!);
    }
  }

  /// Saves data to the specified collection.
  @override
  TaskEither<Failure, Unit> save({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    dynamic db,
  }) {
    return TaskEither.tryCatch(
      () async {
        logger?.debug(
          'SembastDatabase: Entering save, collection: $collection, id: $id',
        );
        final client = db as DatabaseClient? ?? await database;
        logger?.debug('SembastDatabase: Got database client');
        final store = _getStore(collection);
        logger?.debug('SembastDatabase: Got store for collection $collection');
        logger?.debug('SembastDatabase: About to put record');
        await store.record(id).put(client, data);
        logger?.debug('SembastDatabase: Put completed successfully');
        return unit;
      },
      (error, stackTrace) {
        logger?.error('Save failed: $error');
        return DatabaseFailure('Failed to save: $error');
      },
    );
  }

  /// Retrieves data from the specified collection by id.
  @override
  TaskEither<Failure, Map<String, dynamic>?> get({
    required String collection,
    required String id,
  }) {
    return TaskEither.tryCatch(() async {
      final db = await database;
      final store = _getStore(collection);
      final record = await store.record(id).get(db);
      return record;
    }, (error, stackTrace) => DatabaseFailure('Failed to get: $error'));
  }

  /// Retrieves all records from the collection with optional pagination.
  @override
  TaskEither<Failure, List<Map<String, dynamic>>> getAll({
    required String collection,
    int? limit,
    int? offset,
    dynamic db,
  }) {
    return TaskEither.tryCatch(() async {
      final client = db as DatabaseClient? ?? await database;
      final store = _getStore(collection);
      final finder = Finder(limit: limit, offset: offset);
      final records = await store.find(client, finder: finder);
      return records.map((r) => r.value).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to get all: $error'));
  }

  /// Queries records from the collection with filters.
  @override
  TaskEither<Failure, List<Map<String, dynamic>>> query({
    required String collection,
    required Map<String, dynamic> filter,
    int? limit,
    int? offset,
    dynamic db,
  }) {
    return TaskEither.tryCatch(() async {
      final dbToUse = db as DatabaseClient? ?? await database;
      final store = _getStore(collection);
      Filter? queryFilter;
      Filter? customFilter;
      if (filter.isNotEmpty) {
        final filters = <Filter>[];
        for (final entry in filter.entries) {
          final key = entry.key;
          final value = entry.value;
          if (key == '\$custom') {
            customFilter = Filter.custom(
              value as bool Function(RecordSnapshot),
            );
          } else if (value is Map && value.containsKey('\$in')) {
            final list = (value['\$in'] as List).cast<Object>();
            if (list.isEmpty) {
              // No filter
            } else if (list.length == 1) {
              filters.add(Filter.equals(key, list.first));
            } else {
              filters.add(
                Filter.or(list.map((v) => Filter.equals(key, v)).toList()),
              );
            }
          } else {
            filters.add(Filter.equals(key, value));
          }
        }
        if (filters.isNotEmpty) {
          queryFilter = Filter.and(filters);
        }
      }
      final combinedFilter = (queryFilter != null && customFilter != null)
          ? Filter.and([queryFilter, customFilter])
          : (queryFilter ?? customFilter);
      final finder = Finder(
        filter: combinedFilter,
        limit: limit,
        offset: offset,
      );
      final records = await store.find(dbToUse, finder: finder);
      logger?.info(
        'Query collection: $collection, filter: $filter, found ${records.length} records',
      );
      return records.map((r) => r.value).toList();
    }, (error, stackTrace) => DatabaseFailure('Failed to query: $error'));
  }

  /// Deletes a record from the collection.
  @override
  TaskEither<Failure, Unit> delete({
    required String collection,
    required String id,
    dynamic db,
  }) {
    return TaskEither.tryCatch(() async {
      final client = db as DatabaseClient? ?? await database;
      final store = _getStore(collection);
      await store.record(id).delete(client);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to delete: $error'));
  }

  /// Clears all records from the collection.
  @override
  TaskEither<Failure, Unit> clear({required String collection}) {
    return TaskEither.tryCatch(() async {
      final db = await database;
      final store = _getStore(collection);
      await store.delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to clear: $error'));
  }

  /// Clears all records from all collections.
  @override
  TaskEither<Failure, Unit> clearAll() {
    return TaskEither.tryCatch(() async {
      final db = await database;
      await booksStore.delete(db);
      await authorsStore.delete(db);
      await tagsStore.delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to clear all: $error'));
  }

  /// Executes an operation within a database transaction.
  @override
  TaskEither<Failure, Unit> transaction({
    required Future<Unit> Function(dynamic txn) operation,
  }) {
    return TaskEither.tryCatch(() async {
      final db = await database;
      await db.transaction((txn) async {
        await operation(txn);
      });
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Transaction failed: $error'));
  }

  /// Closes the database connection.
  @override
  TaskEither<Failure, Unit> close() {
    return TaskEither.tryCatch(
      () async {
        final db = _database;
        if (db != null) {
          await db.close();
          _database = null;
        }
        return unit;
      },
      (error, stackTrace) =>
          DatabaseFailure('Failed to close database: $error'),
    );
  }
}
