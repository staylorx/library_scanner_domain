import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for retrieving a tag by name.
class GetTagByNameUsecase with Loggable {
  final TagRepository tagRepository;

  GetTagByNameUsecase({Logger? logger, required this.tagRepository});

  /// Retrieves a tag by name.
  Future<Either<Failure, Tag>> call({required String name}) async {
    logger?.info('getByNameUsecase: Entering call with name: $name');
    final result = await tagRepository.getByName(name: name);
    logger?.info('getByNameUsecase: Success in call');
    return result.match(
      (failure) {
        logger?.info('getByNameUsecase: Failure: $failure');
        return Left(failure);
      },
      (tag) {
        logger?.info('getByNameUsecase: Output: ${tag.name}');
        return Right(tag);
      },
    );
  }
}
