import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:slugify/slugify.dart';
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
  Future<Either<Failure, Author>> call({
    required String name,
    String? biography,
    List<AuthorIdPair>? businessIds,
  }) async {
    logger?.info('AddAuthorUsecase: Entering call with name: $name');
    final slugId = AuthorIdPair(
      idType: AuthorIdType.local,
      idCode: slugify(name),
    );
    final author = Author(
      id: const Uuid().v4(),
      name: name,
      biography: biography,
      businessIds: (businessIds ?? [])..add(slugId),
    );
    final addEither = await authorRepository.addAuthor(author: author);
    logger?.info('AddAuthorUsecase: Success in call');
    return addEither.fold((failure) => Left(failure), (author) {
      logger?.info('AddAuthorUsecase: Output: $author');
      return Right(author);
    });
  }
}
