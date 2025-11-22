enum PluginNodeType { menu, plugin }

class PluginNode {
  final String slug;
  final String name;
  final String? description;
  final String? icon;
  final bool enabled;
  final PluginNodeType type;
  final List<PluginNode> children;
  final Map<String, dynamic>? pluginConfig;

  PluginNode({
    required this.slug,
    required this.name,
    this.description,
    this.icon,
    required this.enabled,
    required this.type,
    this.children = const [],
    this.pluginConfig,
  });
}
