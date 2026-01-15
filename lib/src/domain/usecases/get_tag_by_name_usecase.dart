import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case responsible for retrieving a single tag by its ID.
///
/// This use case encapsulates the business logic for fetching a tag
/// from the repository by ID. It provides logging for debugging and
/// error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetTagByNameUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagByNameUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves a tag by its unique ID.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the tag's ID for debugging purposes.
  /// 2. Calls the repository to fetch the tag by ID.
  /// 3. Logs success and the resulting tag's name (or null if not found).
  /// 4. Returns the tag entity or null if not found.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [name] - The unique identifier of the tag to retrieve.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the [Tag] entity on the right.
  Future<Either<Failure, Tag>> call({required String name}) async {
    logger?.info('getByNameUsecase: Entering call with name: $name');
    final result = await tagRepository.getByName(name: name);
    logger?.info('getByNameUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getByNameUsecase: Failure: $failure');
        logger?.info('getByNameUsecase: Exiting call');
        return Left(failure);
      },
      (tag) {
        logger?.info('getByNameUsecase: Output: ${tag.name}');
        logger?.info('getByNameUsecase: Exiting call');
        return Right(tag);
      },
    );
  }
}
