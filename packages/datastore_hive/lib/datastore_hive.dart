/// Hive datastore implementation for the library scanner domain.
library;

export 'src/hive/database/hive_database.dart';
export 'src/hive/datasources/author_datasource.dart';
export 'src/hive/datasources/book_datasource.dart';
export 'src/hive/datasources/tag_datasource.dart';
export 'src/hive/unit_of_work/hive_unit_of_work.dart';
export 'src/hive/unit_of_work/hive_transaction_handle.dart';

export 'src/repositories/author_repository_impl.dart';
export 'src/repositories/book_repository_impl.dart';
export 'src/repositories/tag_repository_impl.dart';

export 'src/id_registry/services/author_id_registry_service.dart';
export 'src/id_registry/services/book_id_registry_service.dart';

export 'src/hive_domain_factory.dart';
