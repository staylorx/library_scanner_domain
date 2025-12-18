import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for retrieving a single tag by its ID.
///
/// This use case encapsulates the business logic for fetching a tag
/// from the repository by ID. It provides logging for debugging and
/// error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetTagByNameUsecase {
  final AbstractTagRepository tagRepository;

  GetTagByNameUsecase({required this.tagRepository});

  final logger = Logger('GetTagByNameUsecase');

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
    logger.info('getTagByNameUsecase: Entering call with name: $name');
    final result = await tagRepository.getTagByName(name: name);
    logger.info('getTagByNameUsecase: Success in call');
    return result.fold((failure) => Left(failure), (tag) {
      logger.info('getTagByNameUsecase: Output: ${tag?.name ?? 'null'}');
      logger.info('getTagByNameUsecase: Exiting call');
      if (tag == null) {
        return Left(NotFoundFailure('Tag not found'));
      }
      return Right(tag);
    });
  }
}
