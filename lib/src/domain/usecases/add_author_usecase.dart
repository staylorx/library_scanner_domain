import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:slugify_string/slugify_string.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new author to the repository.
class AddAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;
  final AuthorIdRegistryService idRegistryService;

  AddAuthorUsecase({
    Logger? logger,
    required this.authorRepository,
    required this.idRegistryService,
  });

  /// Adds a new author and returns the author.
  TaskEither<Failure, Author> call({
    required String name,
    String? biography,
    List<AuthorIdPair>? businessIds,
  }) {
    logger?.info('AddAuthorUsecase: Entering call with name: $name');
    final slugId = AuthorIdPair(
      idType: AuthorIdType.local,
      idCode: Slugify(name).toString(),
    );
    final author = Author(
      id: const Uuid().v4(),
      name: name,
      biography: biography,
      businessIds: (businessIds ?? [])..add(slugId),
    );
    return authorRepository.addAuthor(author: author).map((author) {
      logger?.info('AddAuthorUsecase: Output: $author');
      return author;
    });
  }
}
