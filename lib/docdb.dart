import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'doc.dart';

class DocDB {
  Database? _database;

  Future<List<Doc>> query(Map<String, dynamic> filters,
      {String? dateField,
      DateTime? olderThan,
      DateTime? newerThan,
      DateTime? start,
      DateTime? end,
      int limit = 20,
      int offset = 0,
      String orderBy = 'ASC'}) async {
    var docs = <Doc>[];

    // Prepare the where clause and where arguments
    StringBuffer whereBuffer = StringBuffer();
    List<dynamic> whereArgs = [];

    for (String key in filters.keys) {
      if (whereBuffer.isNotEmpty) {
        whereBuffer.write(' AND ');
      }
      whereBuffer.write(
          'id IN (SELECT doc_id FROM kv_text WHERE key = ? AND value = ?)');
      whereArgs.add(key);
      whereArgs.add(filters[key]);
    }

    String where = whereBuffer.toString();

    List<Map<String, dynamic>> results = await database.query('doc',
        distinct: true,
        where: where.isNotEmpty ? where : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: 'id $orderBy');

    for (var row in results) {
      Doc doc = await get(row['id']);
      if (dateField != null) {
        DateTime dateValue = doc[dateField];
        if (olderThan != null && dateValue.isAfter(olderThan)) {
          continue;
        }
        if (newerThan != null && dateValue.isBefore(newerThan)) {
          continue;
        }
        if (start != null &&
            end != null &&
            (dateValue.isBefore(start) || dateValue.isAfter(end))) {
          continue;
        }
      }
      docs.add(doc);
    }
    return docs;
  }

  Future<List<Doc>> filter(String key, dynamic value,
      {int limit = 20, int offset = 0, String orderBy = 'ASC'}) async {
    var docs = <Doc>[];
    String tableName;
    if (value is int) {
      tableName = 'kv_int';
    } else if (value is double) {
      tableName = 'kv_real';
    } else if (value is String) {
      tableName = 'kv_text';
    } else {
      return docs;
    }

    List<Map<String, dynamic>> results = await database.query(tableName,
        distinct: true,
        where: 'key = ? AND value = ?',
        whereArgs: [key, value],
        limit: limit,
        offset: offset,
        orderBy: 'doc_id $orderBy');

    for (var row in results) {
      docs.add(await get(row['doc_id']));
    }
    return docs;
  }

  Future<List<Doc>> getAll(
      {int limit = 20, int offset = 0, String orderBy = 'ASC'}) async {
    List<Map<String, dynamic>> maps = await database.query('doc',
        orderBy: 'id $orderBy', limit: limit, offset: offset);
    List<Doc> docs = [];
    for (Map<String, dynamic> map in maps) {
      docs.add(await get(map['id']));
    }
    return docs;
  }

  Future<Doc> get(int id) async {
    final doc = Doc();
    final rows = await database.query('doc', where: 'id = ?', whereArgs: [id]);
    if (rows.length != 1) {
      return Doc();
    }
    doc.id = rows[0]["id"] as int;
    for (var table in ['kv_int', 'kv_real', 'kv_text', 'kv_blob']) {
      final kvRows =
          await database.query(table, where: 'doc_id = ?', whereArgs: [id]);
      for (var row in kvRows) {
        dynamic value;
        switch (row['data_type']) {
          case 'integer':
            value = row['value'];
            break;
          case 'real':
            value = row['value'];
            break;
          case 'text':
            value = row['value'];
            break;
          case 'blob':
            value = row['value'];
            break;
          case 'bool':
            value = row['value'] == 1 ? true : false;
            break;
          case 'datetime':
            value = DateTime.fromMillisecondsSinceEpoch(
                int.parse("${row['value']}"));
            break;
        }
        if (row.containsKey('key')) {
          var k = row['key']!;
          doc.fields[k.toString()] = value;
        }
      }
    }
    return doc;
  }

  Future<int> insert(Doc doc) async {
    doc.id = await database
        .insert('doc', {'created_at': DateTime.now().millisecondsSinceEpoch});
    for (var key in doc.fields.keys) {
      var value = doc.fields[key];
      String type;
      String dataType;
      if (value is int) {
        type = 'int';
        dataType = 'integer';
      } else if (value is double) {
        type = 'real';
        dataType = 'real';
      } else if (value is String) {
        type = 'text';
        dataType = 'text';
      } else if (value is Uint8List) {
        type = 'blob';
        dataType = 'blob';
      } else if (value is bool) {
        type = 'int';
        dataType = 'bool';
        value = value ? 1 : 0;
      } else if (value is DateTime) {
        type = 'int';
        dataType = 'datetime';
        value = value.millisecondsSinceEpoch;
      } else {
        continue;
      }
      await database.insert('kv_$type', {
        'doc_id': doc.id,
        'key': key,
        'value': value,
        'data_type': dataType,
      });
    }
    return doc.id;
  }

  Future<void> delete(int docId) async {
    await database.delete('doc', where: 'id = ?', whereArgs: [docId]);
    await database.delete('kv_text', where: 'doc_id = ?', whereArgs: [docId]);
    await database.delete('kv_int', where: 'doc_id = ?', whereArgs: [docId]);
    await database.delete('kv_real', where: 'doc_id = ?', whereArgs: [docId]);
    await database.delete('kv_blob', where: 'doc_id = ?', whereArgs: [docId]);
  }

  Future<void> update(Doc doc) async {
    await database.update(
        'doc', {'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [doc.id]);

    // Doc existingDoc = await get(doc.id);

    for (var key in doc.fields.keys) {
      var value = doc.fields[key];
      String type;
      String dataType;
      if (value is int) {
        type = 'int';
        dataType = 'integer';
      } else if (value is double) {
        type = 'real';
        dataType = 'real';
      } else if (value is String) {
        type = 'text';
        dataType = 'text';
      } else if (value is Uint8List) {
        type = 'blob';
        dataType = 'blob';
      } else if (value is bool) {
        type = 'int';
        dataType = 'bool';
        value = value ? 1 : 0;
      } else if (value is DateTime) {
        type = 'int';
        dataType = 'datetime';
        value = value.millisecondsSinceEpoch;
      } else {
        continue;
      }

      await database.execute('''
      INSERT OR REPLACE INTO kv_$type (id, doc_id, key, value, data_type)
      VALUES (
        (SELECT id FROM kv_$type WHERE doc_id = ? AND key = ?),
        ?,
        ?,
        ?,
        ?
      )
    ''', [doc.id, key, doc.id, key, value, dataType]);

      /*
      if (existingDoc.fields.containsKey(key)) {
        await database.update(
            'kv_$type',
            {
              'doc_id': doc.id,
              'key': key,
              'value': value,
              'data_type': dataType
            },
            where: 'doc_id = ? and key = ?',
            whereArgs: [doc.id, key]);
      } else {
        await database.insert('kv_$type', {
          'doc_id': doc.id,
          'key': key,
          'value': value,
          'data_type': dataType,
        });
      }
      */
    }
  }

  connect({String dbName = 'doc.db'}) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    debugPrint("database path $path");
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE doc (
      id INTEGER PRIMARY KEY,
      created_at INTEGER,
      updated_at INTEGER
    )
    ''');
    await db.execute('''
    CREATE TABLE kv_text (
      id INTEGER PRIMARY KEY,
      doc_id INTEGER,
      key TEXT,
      value TEXT,
      data_type INTEGER,
      FOREIGN KEY (doc_id) REFERENCES doc (id)
    )
    ''');
    await db.execute('''
    CREATE TABLE kv_int (
      id INTEGER PRIMARY KEY,
      doc_id INTEGER,
      key TEXT,
      value INTEGER,
      data_type INTEGER,
      FOREIGN KEY (doc_id) REFERENCES doc (id)
    )
    ''');
    await db.execute('''
    CREATE TABLE kv_real (
      id INTEGER PRIMARY KEY,
      doc_id INTEGER,
      key TEXT,
      value REAL,
      data_type INTEGER,
      FOREIGN KEY (doc_id) REFERENCES doc (id)
    )
    ''');
    await db.execute('''
    CREATE TABLE kv_blob (
      id INTEGER PRIMARY KEY,
      doc_id INTEGER,
      key TEXT,
      value BLOB,
      data_type INTEGER,
      FOREIGN KEY (doc_id) REFERENCES doc (id)
    )
    ''');
  }

  Database get database => _database!;
}
