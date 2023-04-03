import 'package:docdb/doc.dart';
import 'package:docdb/docdb.dart';

void main() async {
  // Initialize DocDB instance and connect to the database
  final db = DocDB();
  await db.connect(dbName: 'example.db');

  // Insert a document
  final doc = Doc();
  doc['title'] = 'Example Document';
  doc['content'] = 'This is an example document.';
  await db.insert(doc);

  // Retrieve the document
  Doc retrievedDoc = await db.get(doc.id);
  print('Retrieved document: ${retrievedDoc.toMap()}');

  // Update the document
  doc['title'] = 'Updated Example Document';
  await db.update(doc);

  // Retrieve the updated document
  final updatedDoc = await db.get(doc.id);
  print('Updated document: ${updatedDoc.toMap()}');

  // Delete the document
  await db.delete(doc.id);

  // Check if the document was deleted
  final deletedDoc = await db.get(doc.id);
  print('Deleted document: ${deletedDoc.toMap()}');
}
