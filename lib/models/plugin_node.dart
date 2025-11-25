enum PluginNodeType { menu, plugin, native }

class PluginNode {
  final String pluginId;
  final String name;
  final String? description;
  final String? icon;
  final bool enabled;
  final PluginNodeType type;

  /// Children only for menu type
  final List<String> childPluginIds;

  /// Enterprise plugin config
  final Map<String, dynamic>? pluginConfig;

  PluginNode({
    required this.pluginId,
    required this.name,
    this.description,
    this.icon,
    required this.enabled,
    required this.type,
    this.childPluginIds = const [],
    this.pluginConfig,
  });
}
