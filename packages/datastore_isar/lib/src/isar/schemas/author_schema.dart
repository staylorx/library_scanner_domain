import 'package:isar/isar.dart';

part 'author_schema.g.dart';

/// FNV-1a 64-bit hash — maps a UUID string to an Isar integer [Id].
///
/// This is the standard pattern from the Isar documentation for string-keyed
/// collections.  The same function is used in all three schema files.
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

/// Isar storage schema for an author.
///
/// Isar requires an integer [Id].  We derive it from the UUID string [stringId]
/// using [fastHash] — the standard pattern for string-keyed Isar collections.
///
/// Heavy data (businessIds serialised as JSON) lives in [dataJson] so we can
/// reconstruct a full AuthorModel from one record read.  Only fields needed
/// for querying are promoted to top-level (indexed) columns.
@collection
class AuthorSchema {
  /// Integer primary key derived from [stringId] via [fastHash].
  Id get id => fastHash(stringId);

  /// The entity's UUID string identifier.
  @Index(unique: true, replace: true)
  late String stringId;

  /// Author name — indexed to support name-based lookups.
  @Index()
  late String name;

  /// Full serialised record (JSON-encoded Map) for round-trip reconstruction.
  late String dataJson;
}
