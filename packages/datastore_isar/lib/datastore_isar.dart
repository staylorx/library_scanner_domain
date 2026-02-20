/// Isar datastore implementation for the library scanner domain.
///
/// Provides full ACID transaction support via Isar's native `writeTxn`.
library;

// Database
export 'src/isar/database/isar_database.dart';

// Schemas (generated)
// fastHash is defined in author_schema.dart; hide duplicates from book/tag.
export 'src/isar/schemas/author_schema.dart';
export 'src/isar/schemas/book_schema.dart' hide fastHash;
export 'src/isar/schemas/tag_schema.dart' hide fastHash;

// Unit of work
export 'src/isar/unit_of_work/isar_transaction_handle.dart';
export 'src/isar/unit_of_work/isar_unit_of_work.dart';

// Datasources
export 'src/isar/datasources/author_datasource.dart';
export 'src/isar/datasources/book_datasource.dart';
export 'src/isar/datasources/tag_datasource.dart';

// Repositories
export 'src/repositories/base_repository.dart';
export 'src/repositories/author_repository_impl.dart';
export 'src/repositories/book_repository_impl.dart';
export 'src/repositories/tag_repository_impl.dart';

// ID Registry services
export 'src/id_registry/services/author_id_registry_service.dart';
export 'src/id_registry/services/book_id_registry_service.dart';
