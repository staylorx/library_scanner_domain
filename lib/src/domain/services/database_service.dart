import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class DatabaseService {
  Future<Either<Failure, void>> save(String collection, String id, Map<String, dynamic> data);

  Future<Either<Failure, Map<String, dynamic>?>> get(String collection, String id);

  Future<Either<Failure, List<Map<String, dynamic>>>> getAll(String collection, {int? limit, int? offset});

  Future<Either<Failure, List<Map<String, dynamic>>>> query(String collection, Map<String, dynamic> filter, {int? limit, int? offset});

  Future<Either<Failure, void>> delete(String collection, String id);

  Future<Either<Failure, void>> clear(String collection);

  Future<Either<Failure, void>> clearAll();

  Future<Either<Failure, void>> transaction(Function() operation);

  Future<void> close();
}