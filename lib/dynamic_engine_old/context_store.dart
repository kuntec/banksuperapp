class DynamicContextStore {
  final Map<String, dynamic> _values = {};

  void setValue(String key, dynamic value) {
    _values[key] = value;
  }

  dynamic getValue(String key) => _values[key];

  Map<String, dynamic> getAll() => Map.unmodifiable(_values);
}
