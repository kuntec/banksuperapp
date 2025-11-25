class DynamicContextStore {
  /// Internal storage, can contain nested maps.
  final Map<String, dynamic> _values = {};

  /// Public: set a value by key or dotted path, e.g. "context.bill.amount".
  void setValue(String key, dynamic value) {
    if (key.contains('.')) {
      _setNested(_values, key.split('.'), value);
    } else {
      _values[key] = value;
    }
  }

  /// Public: get a value by key or dotted path.
  dynamic getValue(String key) {
    if (key.contains('.')) {
      return _getNested(_values, key.split('.'));
    }
    return _values[key];
  }

  /// Read-only snapshot of all context.
  Map<String, dynamic> getAll() => Map.unmodifiable(_values);

  /// Helpers

  dynamic _getNested(Map<String, dynamic> root, List<String> parts) {
    dynamic current = root;
    for (final p in parts) {
      if (current is Map<String, dynamic> && current.containsKey(p)) {
        current = current[p];
      } else {
        return null;
      }
    }
    return current;
  }

  void _setNested(
      Map<String, dynamic> root, List<String> parts, dynamic value) {
    var current = root;
    for (var i = 0; i < parts.length; i++) {
      final key = parts[i];
      final isLast = i == parts.length - 1;
      if (isLast) {
        current[key] = value;
      } else {
        final next = current[key];
        if (next is Map<String, dynamic>) {
          current = next;
        } else {
          final newMap = <String, dynamic>{};
          current[key] = newMap;
          current = newMap;
        }
      }
    }
  }
}
