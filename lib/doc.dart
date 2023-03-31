class Doc {
  int id = 0;
  Map<String, dynamic> fields = {};

  dynamic operator [](String key) => fields[key];
  void operator []=(String key, dynamic value) => fields[key] = value;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'id': id, 'fields': fields};
    return map;
  }

  static Doc fromMap(Map<String, dynamic> map) {
    Doc doc = Doc();
    doc.id = map['id'] as int;
    doc.fields = map['fields'] as Map<String, dynamic>;
    return doc;
  }
}
