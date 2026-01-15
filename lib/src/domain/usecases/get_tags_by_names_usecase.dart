import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for retrieving multiple tags by names.
class GetTagsByNamesUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagsByNamesUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves multiple tags by names.
  Future<Either<Failure, List<Tag>>> call({required List<String> names}) async {
    logger?.info('getTagsByNamesUsecase: Entering call with ids: $names');
    final result = await tagRepository.getTagsByNames(names: names);
    logger?.info('getTagsByNamesUsecase: Success in call');
    return result.fold((failure) => Left(failure), (tags) {
      logger?.info(
        'getTagsByNamesUsecase: Output: ${tags.map((t) => t.name).toList()}',
      );
      return Right(tags);
    });
  }
}
