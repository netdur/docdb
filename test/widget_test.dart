import 'package:docdb/doc.dart';
import 'package:docdb/docdb.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteTestInit();

  group('DocDB', () {
    late DocDB db;

    setUp(() async {
      db = DocDB();
      await db.connect(dbName: 'test.db');
    });

    tearDown(() async {
      await db.database.close();
    });

    test('Inserting and retrieving documents works', () async {
      final doc = Doc();
      doc['title'] = 'Test Document';
      doc['content'] = 'This is a test document';
      await db.insert(doc);

      final retrievedDoc = await db.get(doc.id);
      expect(retrievedDoc['title'], equals('Test Document'));
      expect(retrievedDoc['content'], equals('This is a test document'));
    });

    test('Updating documents works', () async {
      final doc = Doc();
      doc['title'] = 'Test Document';
      await db.insert(doc);

      final retrievedDoc = await db.get(doc.id);
      expect(retrievedDoc['title'], equals('Test Document'));

      doc['title'] = 'Updated Test Document';
      await db.update(doc);

      final updatedDoc = await db.get(doc.id);
      expect(updatedDoc['title'], equals('Updated Test Document'));
    });

    test('Filtering documents works', () async {
      final doc1 = Doc();
      doc1['title'] = 'Test Document 1';
      doc1['status'] = 'draft';
      await db.insert(doc1);

      final doc2 = Doc();
      doc2['title'] = 'Test Document 2';
      doc2['status'] = 'published';
      await db.insert(doc2);

      final drafts = await db.filter('status', 'draft');
      expect(drafts.length, equals(1));
      expect(drafts[0]['title'], equals('Test Document 1'));

      final published = await db.filter('status', 'published');
      expect(published.length, equals(1));
      expect(published[0]['title'], equals('Test Document 2'));
    });

    test('Deleting documents works', () async {
      final doc = Doc();
      doc['title'] = 'Test Document';
      await db.insert(doc);

      await db.delete(doc.id);
      final retrievedDoc = await db.get(doc.id);
      expect(retrievedDoc.id, equals(0));
    });
  });
}
