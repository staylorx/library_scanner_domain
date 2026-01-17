import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_unit_of_work.dart';
import 'package:library_scanner_domain/src/data/sembast/datasources/sembast_database.dart';
import 'package:library_scanner_domain/src/domain/services/database_service.dart';
import 'package:path/path.dart' as p;

class SembastUnitOfWorkBenchmark extends BenchmarkBase {
  SembastUnitOfWorkBenchmark() : super('SembastUnitOfWork.run');

  late DatabaseService database;
  late SembastUnitOfWork unitOfWork;

  @override
  void setup() {
    database = SembastDatabase(testDbPath: p.join('build', 'benchmark_uow'));
    unitOfWork = SembastUnitOfWork(dbService: database);
  }

  @override
  void run() {
    // Benchmark a simple transaction operation
    unitOfWork.run((txn) async => 'benchmark result');
  }

  @override
  void teardown() {
    database.close();
  }
}

void main() {
  SembastUnitOfWorkBenchmark().report();
}
