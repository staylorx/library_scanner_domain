import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';

/// Hive database provider.
///
/// Opens and caches three typed boxes — `books`, `authors`, `tags` — each
/// storing `Map<String, dynamic>` values keyed by the entity's string `id`.
///
/// ## Initialisation
///
/// Hive requires an init path before any box is opened.  Call
/// `Hive.init(path)` (non-Flutter) or `Hive.initFlutter()` (Flutter) before
/// constructing this class, **or** pass [testDir] to let [HiveDatabase]
/// call `Hive.init` internally (useful in tests).
///
/// When [testDir] is `null` the constructor assumes Hive has already been
/// initialised by the caller.
class HiveDatabase with Loggable {
  static const String _booksBoxName = 'books';
  static const String _authorsBoxName = 'authors';
  static const String _tagsBoxName = 'tags';

  /// When set, [HiveDatabase] will call `Hive.init(testDir)` itself.
  ///
  /// Use this in tests: pass a temporary directory path so each test gets an
  /// isolated, on-disk Hive environment.  Leave `null` in production — Hive
  /// is initialised at app start-up before this class is constructed.
  final String? testDir;

  HiveDatabase({this.testDir, Logger? logger}) {
    this.logger = logger;
    if (testDir != null) {
      Hive.init(testDir!);
    }
  }

  Box<Map<dynamic, dynamic>>? _booksBox;
  Box<Map<dynamic, dynamic>>? _authorsBox;
  Box<Map<dynamic, dynamic>>? _tagsBox;

  // ─── Box accessors ────────────────────────────────────────────────────────

  /// Opens (or returns the already-open) books box.
  Future<Box<Map<dynamic, dynamic>>> get booksBox async {
    if (_booksBox != null && _booksBox!.isOpen) return _booksBox!;
    _booksBox = await Hive.openBox<Map<dynamic, dynamic>>(_booksBoxName);
    return _booksBox!;
  }

  /// Opens (or returns the already-open) authors box.
  Future<Box<Map<dynamic, dynamic>>> get authorsBox async {
    if (_authorsBox != null && _authorsBox!.isOpen) return _authorsBox!;
    _authorsBox = await Hive.openBox<Map<dynamic, dynamic>>(_authorsBoxName);
    return _authorsBox!;
  }

  /// Opens (or returns the already-open) tags box.
  Future<Box<Map<dynamic, dynamic>>> get tagsBox async {
    if (_tagsBox != null && _tagsBox!.isOpen) return _tagsBox!;
    _tagsBox = await Hive.openBox<Map<dynamic, dynamic>>(_tagsBoxName);
    return _tagsBox!;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Closes all open boxes.
  Future<void> close() async {
    await _booksBox?.close();
    await _authorsBox?.close();
    await _tagsBox?.close();
    _booksBox = null;
    _authorsBox = null;
    _tagsBox = null;
  }

  /// Deletes all records from all three boxes.
  TaskEither<Failure, Unit> clearAll() {
    return TaskEither.tryCatch(
      () async {
        final books = await booksBox;
        final authors = await authorsBox;
        final tags = await tagsBox;
        await books.clear();
        await authors.clear();
        await tags.clear();
        return unit;
      },
      (error, _) => DatabaseFailure('Failed to clear Hive database: $error'),
    );
  }
}
