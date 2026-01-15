import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';

/// Use case responsible for retrieving all tags from the repository.
///
/// This use case encapsulates the business logic for fetching the complete
/// list of tags. It provides logging for debugging and error handling
/// to ensure robustness.
///
/// The use case follows the Clean Architecture pattern, acting as an
/// intermediary between the presentation layer and the data layer.
class GetTagsUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagsUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves all tags from the repository.
  ///
  /// This method performs the following operations:
  /// 1. Logs the entry for debugging purposes.
  /// 2. Calls the repository to fetch all tags.
  /// 3. Logs success and the resulting list of tag names.
  /// 4. Returns the complete list of tags.
  ///
  /// If an error occurs during the process, it logs the error and rethrows
  /// the exception to allow higher layers to handle it appropriately.
  ///
  /// Returns a [Future] containing [Either] with [Failure] on the left or the list of all [Tag] entities on the right.
  Future<Either<Failure, List<Tag>>> call() async {
    logger?.info('GetTagsUsecase: Entering call');
    final result = await tagRepository.getTags();
    logger?.info('GetTagsUsecase: Success in call');
    return result.fold((failure) => Left(failure), (tags) {
      logger?.info(
        'GetTagsUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      return Right(tags);
    });
  }
}
