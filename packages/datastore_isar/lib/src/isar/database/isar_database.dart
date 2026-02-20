import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';

import '../schemas/author_schema.dart';
import '../schemas/book_schema.dart';
import '../schemas/tag_schema.dart';

/// Isar database provider.
///
/// Opens and caches a single [Isar] instance containing the three collections:
/// [AuthorSchema], [BookSchema], and [TagSchema].
///
/// ## Pure-Dart initialisation
///
/// Isar embeds native libraries in Flutter via `isar_flutter_libs`.  For pure
/// Dart (CLI, tests) you must call [Isar.initializeIsarCore] once before
/// opening any instance.  Pass [download: true] to let Isar download the
/// correct native binary for the current platform on first use (cached
/// permanently in the system temp dir).
///
/// ```dart
/// await Isar.initializeIsarCore(download: true);
/// final db = IsarDatabase(directory: tmp.path);
/// ```
///
/// In Flutter the framework handles initialisation automatically — just
/// construct [IsarDatabase] directly.
class IsarDatabase with Loggable {
  /// Directory where Isar stores its `*.isar` files.
  ///
  /// Must be an absolute path to a writable directory.  In tests, pass a
  /// temporary directory created with [Directory.systemTemp.createTemp].
  final String directory;

  /// Optional Isar instance name — useful when opening multiple databases
  /// in the same process (e.g., per-test isolation).
  final String name;

  IsarDatabase({
    required this.directory,
    this.name = Isar.defaultName,
    Logger? logger,
  }) {
    this.logger = logger;
  }

  Isar? _isar;

  // ─── Instance accessor ────────────────────────────────────────────────────

  /// Returns the open [Isar] instance, opening it lazily on first call.
  Future<Isar> get isar async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    _isar = await _open();
    return _isar!;
  }

  Future<Isar> _open() => Isar.open(
    [AuthorSchemaSchema, BookSchemaSchema, TagSchemaSchema],
    directory: directory,
    name: name,
  );

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Closes the Isar instance and releases native resources.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Clears all records from all three collections in a single write transaction.
  TaskEither<Failure, Unit> clearAll() {
    return TaskEither.tryCatch(
      () async {
        final db = await isar;
        await db.writeTxn(() async {
          await db.authorSchemas.clear();
          await db.bookSchemas.clear();
          await db.tagSchemas.clear();
        });
        return unit;
      },
      (error, _) => DatabaseFailure('Failed to clear Isar database: $error'),
    );
  }
}
