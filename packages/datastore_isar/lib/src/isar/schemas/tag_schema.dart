import 'package:isar/isar.dart';

part 'tag_schema.g.dart';

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

/// Isar storage schema for a tag.
///
/// [bookIds] is stored as a native [List<String>] column so element-level
/// queries (which books are under tag X?) can use the Isar index.
@collection
class TagSchema {
  Id get id => fastHash(stringId);

  @Index(unique: true, replace: true)
  late String stringId;

  /// Tag name — indexed and unique (tags are identified by name).
  @Index(unique: true, replace: true)
  late String name;

  /// Book UUID strings — element-indexed for tag→books lookups.
  @Index()
  late List<String> bookIds;

  /// Full serialised record (JSON-encoded Map) for round-trip reconstruction.
  late String dataJson;
}
