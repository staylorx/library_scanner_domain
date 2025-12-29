import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AbstractTagRepository {
  Future<Either<Failure, List<Tag>>> getTags();
  Future<Either<Failure, Tag?>> getTagByName({required String name});
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  });
  Future<Either<Failure, Unit>> addTag({required Tag tag});
  Future<Either<Failure, Unit>> updateTag({
    required Tag oldTag,
    required Tag newTag,
  });
  Future<Either<Failure, Unit>> deleteTag({required Tag tag});
}
