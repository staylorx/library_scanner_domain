import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for retrieving a single author by their name.
///
/// This use case encapsulates the business logic for fetching an author
/// from the repository by name. It provides logging for debugging and
/// error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetAuthorByNameUsecase {
  final IAuthorRepository authorRepository;

  GetAuthorByNameUsecase({required this.authorRepository});

  final logger = Logger('GetAuthorByNameUsecase');

  /// Retrieves an author by their name.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the author's name for debugging purposes.
  /// 2. Calls the repository to fetch the author by name.
  /// 3. Logs success and the resulting author's name (or null if not found).
  /// 4. Returns the author entity or null if not found.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [name] - The name of the author to retrieve.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the [Author] entity on the right.
  Future<Either<Failure, Author>> call({required String name}) async {
    logger.info('GetAuthorByNameUsecase: Entering call with name: $name');
    final result = await authorRepository.getAuthorByName(name: name);
    logger.info('GetAuthorByNameUsecase: Success in call');
    return result.fold((failure) => Left(failure), (author) {
      logger.info('GetAuthorByNameUsecase: Output: ${author?.name ?? 'null'}');
      logger.info('GetAuthorByNameUsecase: Exiting call');
      if (author == null) {
        return Left(NotFoundFailure('Author not found'));
      }
      return Right(author);
    });
  }
}
