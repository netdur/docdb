# DocDB

DocDB is a simple document database for Flutter that stores document metadata in one table and key-value pairs in separate tables for each data type. It is not an ORM for SQLite.

## Installation
Add docdb as a dependency in your pubspec.yaml file:


```yaml
dependencies:
  docdb:
```
Then run `flutter pub get` to install the package.

## Usage
Connecting to the database
Before you can use DocDB, you need to connect to a database. You can use the connect method to do this:

```dart
import 'package:docdb/docdb.dart';

final db = DocDB();
await db.connect(dbName: 'mydb.db');
```
The connect method creates the database file if it doesn't exist and opens a connection to the database.

## Storing documents
To store a document, create a Doc object and add fields to it:

```dart
final doc = Doc();
doc['title'] = 'My Document';
doc['content'] = 'Lorem ipsum dolor sit amet...';
await db.insert(doc);
```
The insert method adds the document to the database and returns the document ID.

## Retrieving documents
To retrieve a document, use the get method:

```dart
final docId = 1; // ID of the document to retrieve
final doc = await db.get(docId);
print(doc['title']); // Prints the title of the document
```
The get method returns a Doc object with the specified ID.

## Updating documents
To update a document, retrieve it using the get method, modify its fields, and then call the update method:

```dart
final docId = 1; // ID of the document to update
final doc = await db.get(docId);
doc['title'] = 'New Title';
await db.update(doc);
```
The update method saves the changes to the database.

## Deleting documents
To delete a document, use the delete method:

```dart
final docId = 1; // ID of the document to delete
await db.delete(docId);
```
The delete method removes the document and its associated key-value pairs from the database.

## Filtering documents
You can filter documents by a specific field value using the filter method:

```dart
final docs = await db.filter('title', 'My Document');
print(docs.length); // Prints the number of documents with the specified title
```
The filter method returns a list of Doc objects that match the specified criteria.

## Querying documents
You can query documents with multiple filters and date constraints using the query method:

```dart
List<Doc> docs = await db.query(
  {'_collection': 'xyz', 'status': 'active'},
  dateField: 'created',
  olderThan: DateTime.now().subtract(const Duration(days: 3)),
);
```
The query method returns a list of Doc objects that match the specified criteria and date constraints.

## License
DocDB is released under the MIT License. See LICENSE for details.