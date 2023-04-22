import 'dart:io';

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
      final file = File('.dart_tool/sqflite_common_ffi/databases/test.db');
      await file.delete();
    });

    test('Insert and retrieve documents', () async {
      // Insert a test document
      final doc = Doc();
      doc['title'] = 'Test Document';
      doc['content'] = 'This is a test document';
      await db.insert(doc);

      // Retrieve the inserted document
      final retrievedDoc = await db.get(doc.id);
      expect(retrievedDoc['title'], equals('Test Document'));
      expect(retrievedDoc['content'], equals('This is a test document'));
    });

    test('Update documents', () async {
      // Insert a test document
      final doc = Doc();
      doc['title'] = 'Test Document';
      await db.insert(doc);

      // Update the document title
      doc['title'] = 'Updated Test Document';
      await db.update(doc);

      // Retrieve the updated document
      final updatedDoc = await db.get(doc.id);
      expect(updatedDoc['title'], equals('Updated Test Document'));
    });

    test('Update documents with new fields', () async {
      // Insert a test document
      final doc = Doc();
      doc['title'] = 'Test Document';
      await db.insert(doc);

      // Update the document title
      doc['title'] = 'Updated Test Document';
      doc['new_value'] = true;
      await db.update(doc);

      // Retrieve the updated document
      final updatedDoc = await db.get(doc.id);
      expect(updatedDoc['new_value'], equals(true));
    });

    test('Filter documents by single field', () async {
      // Insert two test documents with different statuses
      final doc1 = Doc();
      doc1['title'] = 'Test Document 1';
      doc1['status'] = 'draft';
      await db.insert(doc1);

      final doc2 = Doc();
      doc2['title'] = 'Test Document 2';
      doc2['status'] = 'published';
      await db.insert(doc2);

      // Filter documents by status
      final drafts = await db.filter('status', 'draft');
      expect(drafts.length, equals(1));
      expect(drafts[0]['title'], equals('Test Document 1'));

      final published = await db.filter('status', 'published');
      expect(published.length, equals(1));
      expect(published[0]['title'], equals('Test Document 2'));
    });

    test('Delete documents', () async {
      // Insert a test document
      final doc = Doc();
      doc['title'] = 'Test Document';
      await db.insert(doc);

      // Delete the document
      await db.delete(doc.id);
      final retrievedDoc = await db.get(doc.id);
      expect(retrievedDoc.id, equals(0));
    });

    test('Query with multiple filters and date constraints', () async {
      // Insert test documents
      for (int i = 0; i < 5; i++) {
        Doc doc = Doc();
        doc['_collection'] = 'xyz';
        doc['status'] = i % 2 == 0 ? 'active' : 'inactive';
        doc['created'] = DateTime.now().subtract(Duration(days: i));
        await db.insert(doc);
      }

      // Query documents with multiple filters and date constraints
      List<Doc> docs = await db.query(
          {'_collection': 'xyz', 'status': 'active'},
          dateField: 'created',
          olderThan: DateTime.now().subtract(const Duration(days: 3)));

      // Expect 1 document to match the query
      expect(docs.length, 1);
    });

    test('Query with date range filter', () async {
      // Insert test documents
      for (int i = 0; i < 5; i++) {
        Doc doc = Doc();
        doc['_collection'] = 'xyz';
        doc['created'] = DateTime.now().subtract(Duration(days: i));
        await db.insert(doc);
      }

      // Query documents with date range filter
      List<Doc> docs = await db.query({},
          dateField: 'created',
          start: DateTime.now().subtract(const Duration(days: 2)),
          end: DateTime.now().subtract(const Duration(days: 1)));

      // Expect 1 document to match the query
      expect(docs.length, 1);
    });

    test('Order results by field', () async {
      // Insert test documents with different 'sum' values
      Doc doc = Doc();
      doc['_collection'] = 'sum';
      doc['sum'] = 1;
      await db.insert(doc);

      doc = Doc();
      doc['_collection'] = 'sum';
      doc['sum'] = 3;
      await db.insert(doc);

      doc = Doc();
      doc['_collection'] = 'sum';
      doc['sum'] = 2;
      await db.insert(doc);

      // Query all documents in 'sum' collection
      final docs = await db.filter('_collection', 'sum');
      expect(docs[0]['sum'], equals(1));
      expect(docs[1]['sum'], equals(3));
      expect(docs[2]['sum'], equals(2));
    });
  });
}
