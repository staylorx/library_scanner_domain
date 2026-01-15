import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case for adding a new author to the repository.
class AddAuthorUsecase {
  final AuthorRepository authorRepository;
  final AbstractAuthorIdRegistryService idRegistryService;

  AddAuthorUsecase({
    required this.authorRepository,
    required this.idRegistryService,
  });

  final logger = Logger('AddAuthorUsecase');

  /// Adds a new author and returns the handle.
  Future<Either<Failure, AuthorHandle>> call({
    required String name,
    String? biography,
  }) async {
    logger.info('AddAuthorUsecase: Entering call with name: $name');
    final idEither = await idRegistryService.generateLocalId();
    return idEither.fold((failure) => Left(failure), (idCode) async {
      final idPair = AuthorIdPair(idType: AuthorIdType.local, idCode: idCode);
      final author = Author(
        businessIds: [idPair],
        name: name,
        biography: biography,
      );
      final addEither = await authorRepository.addAuthor(author: author);
      logger.info('AddAuthorUsecase: Success in call');
      return addEither.fold((failure) => Left(failure), (handle) {
        logger.info('AddAuthorUsecase: Output: $handle');
        logger.info('AddAuthorUsecase: Exiting call');
        return Right(handle);
      });
    });
  }
}
