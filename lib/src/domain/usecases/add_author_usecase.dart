import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case for adding a new author to the repository.
class AddAuthorUsecase {
  final AbstractAuthorRepository authorRepository;
  final AbstractAuthorIdRegistryService idRegistryService;

  AddAuthorUsecase({
    required this.authorRepository,
    required this.idRegistryService,
  });

  final logger = Logger('AddAuthorUsecase');

  /// Adds a new author and returns the updated list of authors.
  Future<Either<Failure, List<Author>>> call({
    required String name,
    String? biography,
  }) async {
    logger.info('AddAuthorUsecase: Entering call with name: $name');
    final idEither = await idRegistryService.generateLocalId();
    return idEither.fold((failure) => Left(failure), (idCode) async {
      final idPair = AuthorIdPair(idType: AuthorIdType.local, idCode: idCode);
      final idPairs = AuthorIdPairs(pairs: [idPair]);
      final author = Author(idPairs: idPairs, name: name, biography: biography);
      final addEither = await authorRepository.addAuthor(author: author);
      return addEither.fold((failure) => Future.value(Left(failure)), (
        _,
      ) async {
        final getEither = await authorRepository.getAuthors();
        logger.info('AddAuthorUsecase: Success in call');
        return getEither.fold((failure) => Left(failure), (authors) {
          logger.info(
            'AddAuthorUsecase: Output: ${authors.map((a) => a.name).toList()}',
          );
          logger.info('AddAuthorUsecase: Exiting call');
          return Right(authors);
        });
      });
    });
  }
}
