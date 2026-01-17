import 'package:test/test.dart';
import 'package:library_scanner_domain/src/data/sembast/unit_of_work/sembast_transaction.dart';
import 'package:library_scanner_domain/src/domain/repositories/unit_of_work.dart';

void main() {
  group('SembastTransaction', () {
    test('implements Transaction interface', () {
      final mockDb = 'mock database';
      final transaction = SembastTransaction(mockDb);

      expect(transaction, isA<Transaction>());
    });

    test('holds the provided db instance', () {
      final mockDb = 'mock database instance';
      final transaction = SembastTransaction(mockDb);

      expect(transaction.db, mockDb);
    });

    test('db is accessible', () {
      final mockDb = <String, dynamic>{'key': 'value'};
      final transaction = SembastTransaction(mockDb);

      expect(transaction.db, mockDb);
      expect(transaction.db['key'], 'value');
    });
  });
}
