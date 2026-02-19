import 'package:datastore_sembast/datastore_sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:test/test.dart';

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
