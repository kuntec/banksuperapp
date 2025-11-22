import 'dart:convert';

import 'package:superbankapp/models/plugin_node.dart';

class PluginNodeParser {
  static List<PluginNode> parseRoot(String jsonString) {
    final decoded = json.decode(jsonString) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception('API returned success=false');
    }

    final List<dynamic> dataList = decoded['data'] ?? [];
    return dataList.map<PluginNode>((item) {
      return _parseRootItem(item as Map<String, dynamic>);
    }).toList();
  }

  static PluginNode _parseRootItem(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? '').toString().toLowerCase();
    final type =
        typeStr == 'menu' ? PluginNodeType.menu : PluginNodeType.plugin;

    if (type == PluginNodeType.menu) {
      final childrenJson = json['children'] as List<dynamic>? ?? [];

      final children = childrenJson
          .map<PluginNode>((child) => _parseChildPlugin(child))
          .toList();

      return PluginNode(
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        icon: json['icon']?.toString(),
        enabled: json['enabled'] == true,
        type: PluginNodeType.menu,
        children: children,
      );
    } else {
      final pluginConfig = <String, dynamic>{
        'plugin_slug': json['slug'],
        'version': json['version'] ?? '1.0.0',
        'screens': json['screens'] ?? [],
        'apis': json['apis'] ?? [],
        'flow': json['flow'] ?? [],
      };

      return PluginNode(
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        icon: json['icon']?.toString(),
        enabled: json['enabled'] == true,
        type: PluginNodeType.plugin,
        pluginConfig: pluginConfig,
      );
    }
  }

  static PluginNode _parseChildPlugin(Map<String, dynamic> json) {
    final slug = json['plugin_slug']?.toString() ?? '';

    final pluginConfig = <String, dynamic>{
      'plugin_slug': slug,
      'version': json['version'] ?? '1.0.0',
      'screens': json['screens'] ?? [],
      'apis': json['apis'] ?? [],
      'flow': json['flow'] ?? [],
    };
    return PluginNode(
      slug: slug,
      name: slug,
      description: null,
      icon: null,
      enabled: true,
      type: PluginNodeType.plugin,
      pluginConfig: pluginConfig,
    );
  }
}
