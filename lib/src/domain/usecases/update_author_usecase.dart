import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

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
  final IAuthorRepository authorRepository;

  UpdateAuthorUsecase(this.authorRepository);

  final logger = DevLogger('UpdateAuthorUsecase');

  /// Updates an existing author in the repository and returns the updated list of authors.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the author's name for debugging purposes.
  /// 2. Calls the repository to update the author.
  /// 3. Retrieves the updated list of all authors.
  /// 4. Logs success and the resulting author names.
  /// 5. Returns the complete list of authors after the update.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [author] - The author entity with updated information to be saved.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all authors on the right.
  Future<Either<Failure, List<Author>>> call({required Author author}) async {
    logger.info(
      'UpdateAuthorUsecase: Entering call with author: ${author.name}',
    );
    final updateEither = await authorRepository.updateAuthor(author: author);
    return updateEither.fold((failure) => Future.value(Left(failure)), (
      _,
    ) async {
      final getEither = await authorRepository.getAuthors();
      logger.info('UpdateAuthorUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (authors) {
        logger.info(
          'UpdateAuthorUsecase: Output: ${authors.map((a) => a.name).toList()}',
        );
        logger.info('UpdateAuthorUsecase: Exiting call');
        return Right(authors);
      });
    });
  }
}
