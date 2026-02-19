import 'package:domain_entities/domain_entities.dart';
import 'package:fpdart/fpdart.dart';

abstract class BasicCrudContract<T> {
  TaskEither<Failure, T> create({required T item, UnitOfWork<TransactionHandle>? txn});

  TaskEither<Failure, List<T>> getAll();

  TaskEither<Failure, T> getById({required String id});

  TaskEither<Failure, Unit> deleteAll({UnitOfWork<TransactionHandle>? txn});

  TaskEither<Failure, Unit> deleteById({required T item, UnitOfWork<TransactionHandle>? txn});

  TaskEither<Failure, T> update({required T item, UnitOfWork<TransactionHandle>? txn});
}
