import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Projection class for tag with handle
class TagProjection {
  final TagHandle handle;
  final Tag tag;

  const TagProjection({required this.handle, required this.tag});
}

abstract class TagRepository {
  Future<Either<Failure, List<Tag>>> getTags();
  Future<Either<Failure, Tag?>> getTagByName({required String name});
  Future<Either<Failure, List<Tag>>> getTagsByNames({
    required List<String> names,
  });
  Future<Either<Failure, TagHandle>> addTag({required Tag tag});
  Future<Either<Failure, Unit>> updateTag({
    required TagHandle handle,
    required Tag tag,
  });
  Future<Either<Failure, Unit>> deleteTag({required TagHandle handle});
  Future<Either<Failure, Tag?>> getTagByHandle({required TagHandle handle});
}
