# Getting Started with DocDB

DocDB is a SQLite-based document store for Flutter, designed to provide an easy way to store, manage, and query documents.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  docdb: ^latest_version
```
Replace latest_version with the current version of the package.

Basic Usage
Import the package:
```dart
import 'package:docdb/docdb.dart';
```

Create and configure a DocDB instance:
```dart
final db = DocDB();
await db.connect(dbName: 'your_database_name.db');
```

Insert a document:
```dart
final doc = Doc();
doc['title'] = 'Test Document';
doc['content'] = 'This is a test document';
await db.insert(doc);
```

Retrieve a document:
```dart
final retrievedDoc = await db.get(doc.id);
```

Update a document:

```dart
doc['title'] = 'Updated Test Document';
await db.update(doc);
```

Delete a document:

```dart
await db.delete(doc.id);
```
Query documents:

```dart
final docs = await db.query({'_collection': 'xyz', 'status': 'active'});
```
For more advanced usage, refer to the API documentation and the examples provided in the example directory.