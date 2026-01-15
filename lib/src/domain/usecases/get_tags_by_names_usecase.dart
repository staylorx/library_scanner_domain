import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

/// Use case responsible for retrieving multiple tags by their IDs.
///
/// This use case encapsulates the business logic for fetching a list of
/// tags from the repository by their IDs. It provides logging for
/// debugging and error handling to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetTagsByNamesUsecase {
  final TagRepository tagRepository;

  GetTagsByNamesUsecase({required this.tagRepository});

  final logger = Logger('GetTagsByNamesUsecase');

  /// Retrieves multiple tags by their unique IDs.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry with the list of IDs for debugging purposes.
  /// 2. Calls the repository to fetch tags by IDs.
  /// 3. Logs success and the resulting list of tag names.
  /// 4. Returns the list of tags found (may be fewer than requested if some IDs don't exist).
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// [names] - The list of unique identifiers of the tags to retrieve.
  /// Returns a [Future] containing [Either] with [Failure] on the left or the list of [Tag] entities found on the right.
  Future<Either<Failure, List<Tag>>> call({required List<String> names}) async {
    logger.info('getTagsByNamesUsecase: Entering call with ids: $names');
    final result = await tagRepository.getTagsByNames(names: names);
    logger.info('getTagsByNamesUsecase: Success in call');
    return result.fold((failure) => Left(failure), (tags) {
      logger.info(
        'getTagsByNamesUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      logger.info('getTagsByNamesUsecase: Exiting call');
      return Right(tags);
    });
  }
}
