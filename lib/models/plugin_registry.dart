import 'package:superbankapp/models/plugin_node.dart';

class PluginRegistry {
  static final Map<String, PluginNode> _registry = {};

  static void registerAll(List<PluginNode> nodes) {
    for (final n in nodes) {
      _registry[n.pluginId] = n;
    }
  }

  static PluginNode? get(String pluginId) {
    return _registry[pluginId];
  }
}
