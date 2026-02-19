import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';
import 'basic_crud_contract.dart';
import 'unit_of_work.dart';

abstract class TagRepository implements BasicCrudContract<Tag> {
  @override
  TaskEither<Failure, List<Tag>> getAll();

  TaskEither<Failure, Tag> getByName({required String name});

  TaskEither<Failure, List<Tag>> getTagsByNames({required List<String> names});

  @override
  TaskEither<Failure, Tag> create({required Tag item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Tag> update({required Tag item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Unit> deleteById({required Tag item, UnitOfWork? txn});

  @override
  TaskEither<Failure, Unit> deleteAll({UnitOfWork? txn});
}
