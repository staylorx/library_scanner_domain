import 'package:library_scanner_domain/library_scanner_domain.dart';

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
