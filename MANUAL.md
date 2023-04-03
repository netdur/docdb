# DocDB Manual
DocDB is a simple document database for Flutter that stores document metadata in one table and key-value pairs in separate tables for each data type. It is not an ORM for SQLite.

This manual describes the Doc and DocDB classes, which are the core components of DocDB. It explains the methods and properties of these classes and provides examples of how to use them.

## Doc Class
The Doc class represents a document in the database. A document is a collection of key-value pairs, where keys are strings and values can be of different data types.

### Properties
* id: The unique identifier of the document. It is an integer value and is set automatically when the document is inserted into the database.
* fields: A map that contains the key-value pairs of the document. The keys are strings, and the values can be of different data types, including integers, doubles, strings, binary data (Uint8List), booleans, and DateTime objects.
### Methods
* toMap: Converts the document to a map, which includes the document ID and the fields map.
* fromMap: Creates a new Doc instance from the given map.


## DocDB Class
The DocDB class provides methods to interact with the database, including connecting to the database, creating, updating, retrieving, and deleting documents, and filtering documents by specific criteria.

### Methods
* connect:
    * Input: {String dbName = 'doc.db'}
    * Output: Future<void>
* insert:
    * Input: Doc doc
    * Output: Future<int> (document ID)
* get:
    * Input: int id
    * Output: Future<Doc>
* update:
    * Input: Doc doc
    * Output: Future<void>
* delete:
    * Input: int docId
    * Output: Future<void>
* getAll:
    * Input: {int limit = 20, int offset = 0, String orderBy = 'ASC'}
    * Output: Future<List<Doc>>
* filter:
    * Input: String key, dynamic value, {int limit = 20, int offset = 0, String orderBy = 'ASC'}
    * Output: Future<List<Doc>>
* query:
    * Input: Map<String, dynamic> filters, {String? dateField, DateTime? olderThan, DateTime? newerThan, DateTime? start, DateTime? end, int limit = 20, int offset = 0, String orderBy = 'ASC'}
    * Output: Future<List<Doc>>
