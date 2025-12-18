import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for deleting an author from the repository.
///
/// This use case encapsulates the business logic for deleting an author
/// by ID, including fetching the author first to ensure it exists,
/// performing the deletion, and retrieving the updated list of authors.
/// It provides logging for debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class DeleteAuthorUsecase {
  final AbstractAuthorRepository authorRepository;

  DeleteAuthorUsecase({required this.authorRepository});

  final logger = Logger('DeleteAuthorUsecase');

  /// Deletes an author by name and returns the updated list of authors.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the author's name for debugging purposes.
  /// 2. Fetches the author by name to verify existence.
  /// 3. If the author exists, deletes it from the repository.
  /// 4. Retrieves the updated list of all authors.
  /// 5. Logs success and the resulting author names.
  /// 6. Returns the complete list of authors after the deletion.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [name] - The name of the author to be deleted.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the updated list of all authors on the right.
  Future<Either<Failure, List<Author>>> call({required String name}) async {
    logger.info('DeleteAuthorUsecase: Entering call with name: $name');
    final getAuthorsEither = await authorRepository.getAuthors();
    return getAuthorsEither.fold((failure) => Left(failure), (authors) async {
      final author = authors.where((a) => a.name == name).firstOrNull;
      if (author == null) {
        return Left(NotFoundFailure('Author not found'));
      }
      logger.info('DeleteAuthorUsecase: Deleting author: ${author.name}');
      final deleteEither = await authorRepository.deleteAuthor(author: author);
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedAuthors = authors.where((a) => a.name != name).toList();
        logger.info('DeleteAuthorUsecase: Success in call');
        logger.info(
          'DeleteAuthorUsecase: Output: ${updatedAuthors.map((a) => a.name).toList()}',
        );
        logger.info('DeleteAuthorUsecase: Exiting call');
        return Right(updatedAuthors);
      });
    });
  }
}
