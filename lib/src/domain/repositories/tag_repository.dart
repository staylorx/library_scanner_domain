import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class TagRepository {
  Future<Either<Failure, List<Tag>>> getTags();
  Future<Either<Failure, Tag>> getByName({required String name});
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  });
  Future<Either<Failure, Tag>> addTag({required Tag tag});
  Future<Either<Failure, Unit>> updateTag({required Tag tag});
  Future<Either<Failure, Unit>> deleteTag({required Tag tag});
  Future<Either<Failure, Tag>> getById({required String id});
}
