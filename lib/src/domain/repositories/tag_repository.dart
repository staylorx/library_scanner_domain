import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class TagRepository {
  TaskEither<Failure, List<Tag>> getTags();
  TaskEither<Failure, Tag> getTagByName({required String name});
  TaskEither<Failure, List<Tag>> getTagsByNames({required List<String> names});
  TaskEither<Failure, Tag> addTag({required Tag tag, Transaction? txn});
  TaskEither<Failure, Unit> updateTag({required Tag tag, Transaction? txn});
  TaskEither<Failure, Unit> deleteTag({required Tag tag, Transaction? txn});
  TaskEither<Failure, Tag> getTagById({required String id});
}
