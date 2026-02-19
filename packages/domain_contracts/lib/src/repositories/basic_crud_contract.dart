import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';

import 'unit_of_work.dart';

abstract class BasicCrudContract<T> {
  TaskEither<Failure, T> create({required T item, UnitOfWork? txn});

  TaskEither<Failure, List<T>> getAll();

  TaskEither<Failure, T> getById({required String id});

  TaskEither<Failure, Unit> deleteAll({UnitOfWork? txn});

  TaskEither<Failure, Unit> deleteById({required T item, UnitOfWork? txn});

  TaskEither<Failure, T> update({required T item, UnitOfWork? txn});
}
