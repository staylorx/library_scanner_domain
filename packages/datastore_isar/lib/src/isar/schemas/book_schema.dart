import 'package:isar/isar.dart';

part 'book_schema.g.dart';

/// FNV-1a 64-bit hash — maps a UUID string to an Isar integer [Id].
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

/// Isar storage schema for a book.
///
/// [authorIds] and [tagIds] are stored as native [List<String>] columns so
/// Isar can index individual elements and filter on them efficiently
/// (e.g. "books by author X").
///
/// All other fields that are not needed for indexed queries live in [dataJson].
@collection
class BookSchema {
  Id get id => fastHash(stringId);

  @Index(unique: true, replace: true)
  late String stringId;

  @Index()
  late String title;

  /// Author UUID strings — element-indexed for author→books lookups.
  @Index()
  late List<String> authorIds;

  /// Tag UUID strings — element-indexed for tag→books lookups.
  @Index()
  late List<String> tagIds;

  /// Full serialised record (JSON-encoded Map) for round-trip reconstruction.
  late String dataJson;
}
