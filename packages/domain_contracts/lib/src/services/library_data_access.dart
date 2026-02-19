import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/tag_repository.dart';
import 'author_id_registry_service.dart';
import 'book_id_registry_service.dart';
import 'package:domain_entities/domain_entities.dart';

/// Encapsulates all data access services for library operations.
/// Provides a single injection point for usecases that need multiple data services.
class LibraryDataAccess {
  final AuthorRepository authorRepository;
  final BookRepository bookRepository;
  final TagRepository tagRepository;
  final AuthorIdRegistryService authorIdRegistryService;
  final BookIdRegistryService bookIdRegistryService;
  final UnitOfWork<TransactionHandle> unitOfWork;

  const LibraryDataAccess({
    required this.authorRepository,
    required this.bookRepository,
    required this.tagRepository,
    required this.authorIdRegistryService,
    required this.bookIdRegistryService,
    required this.unitOfWork,
  });
}
