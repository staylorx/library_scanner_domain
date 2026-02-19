import '../repositories/unit_of_work.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/tag_repository.dart';
import 'database_service.dart';
import 'author_id_registry_service.dart';
import 'book_id_registry_service.dart';

/// Encapsulates all data access services for library operations.
/// Provides a single injection point for usecases that need multiple data services.
class LibraryDataAccess {
  final UnitOfWork unitOfWork;
  final DatabaseService databaseService;
  final AuthorRepository authorRepository;
  final BookRepository bookRepository;
  final TagRepository tagRepository;
  final AuthorIdRegistryService authorIdRegistryService;
  final BookIdRegistryService bookIdRegistryService;

  const LibraryDataAccess({
    required this.unitOfWork,
    required this.databaseService,
    required this.authorRepository,
    required this.bookRepository,
    required this.tagRepository,
    required this.authorIdRegistryService,
    required this.bookIdRegistryService,
  });
}
