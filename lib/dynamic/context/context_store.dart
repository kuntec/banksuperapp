class DynamicContextStore {
  final Map<String, dynamic> _values = {};

  void setValue(String key, dynamic value) {
    _values[key] = value;
  }

  dynamic getValue(String? key) {
    if (key == null || key.isEmpty) return null;

    if (key.contains('.')) {
      final parts = key.split('.');
      dynamic current = _values;
      for (final p in parts) {
        if (current is Map && current.containsKey(p)) {
          current = current[p];
        } else {
          return null;
        }
      }
      return current;
    }

    return _values[key];
  }

  Map<String, dynamic> getAll() => Map.unmodifiable(_values);
}
