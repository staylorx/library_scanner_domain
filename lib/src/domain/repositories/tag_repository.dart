import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'basic_crud_contract.dart';

abstract class TagRepository implements BasicCrudContract<Tag> {
  @override
  TaskEither<Failure, List<Tag>> getAll();

  TaskEither<Failure, Tag> getByName({required String name});

  TaskEither<Failure, List<Tag>> getTagsByNames({required List<String> names});

  @override
  TaskEither<Failure, Tag> create({required Tag item, Transaction? txn});

  @override
  TaskEither<Failure, Tag> update({required Tag item, Transaction? txn});

  @override
  TaskEither<Failure, Unit> deleteById({required Tag item, Transaction? txn});

  @override
  TaskEither<Failure, Tag> getById({required String id});

  @override
  TaskEither<Failure, Unit> deleteAll({Transaction? txn});
}
