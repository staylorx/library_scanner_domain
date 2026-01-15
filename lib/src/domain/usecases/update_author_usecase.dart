import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for updating an existing author in the repository.
///
/// This use case encapsulates the business logic for updating an author,
/// including validation through the repository layer and retrieving the
/// updated list of authors after successful update. It provides logging
/// for debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class UpdateAuthorUsecase {
  final AuthorRepository authorRepository;

  UpdateAuthorUsecase({required this.authorRepository});

  final logger = Logger('UpdateAuthorUsecase');

  /// Updates an existing author in the repository.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the author's name for debugging purposes.
  /// 2. Calls the repository to update the author.
  /// 3. Logs success.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [handle] - The handle of the author to update.
  /// [author] - The author entity with updated information to be saved.
  /// Returns a [Future] containing [Either] with [Failure] on the left or Unit on the right.
  Future<Either<Failure, Unit>> call({
    required AuthorHandle handle,
    required Author author,
  }) async {
    logger.info(
      'UpdateAuthorUsecase: Entering call with handle: $handle and author: ${author.name}',
    );
    final updateEither = await authorRepository.updateAuthor(
      handle: handle,
      author: author,
    );
    logger.info('UpdateAuthorUsecase: Success in call');
    return updateEither.fold((failure) => Left(failure), (_) {
      logger.info('UpdateAuthorUsecase: Exiting call');
      return Right(unit);
    });
  }
}
