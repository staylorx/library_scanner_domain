/// Sembast datastore implementation for the library scanner domain.
library;

export 'src/sembast/datasources/sembast_database.dart';
export 'src/sembast/datasources/author_datasource.dart';
export 'src/sembast/datasources/book_datasource.dart';
export 'src/sembast/datasources/tag_datasource.dart';
export 'src/sembast/unit_of_work/sembast_unit_of_work.dart';
export 'src/sembast/unit_of_work/sembast_transaction_handle.dart';

export 'src/repositories/author_repository_impl.dart';
export 'src/repositories/book_repository_impl.dart';
export 'src/repositories/tag_repository_impl.dart';

export 'src/id_registry/services/author_id_registry_service.dart';
export 'src/id_registry/services/book_id_registry_service.dart';

export 'src/sembast_domain_factory.dart';