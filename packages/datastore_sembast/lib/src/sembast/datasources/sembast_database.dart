import 'package:id_logging/id_logging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

/// Sembast database provider.
class SembastDatabase with Loggable {
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

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Clears all data from all stores.
  TaskEither<Failure, Unit> clearAll() {
    return TaskEither.tryCatch(() async {
      final db = await database;
      await booksStore.delete(db);
      await authorsStore.delete(db);
      await tagsStore.delete(db);
      return unit;
    }, (error, stackTrace) => DatabaseFailure('Failed to clear database: $error'));
  }
}