import 'dart:convert';

import 'package:superbankapp/models/plugin_node.dart';
import 'package:superbankapp/models/plugin_registry.dart';

class PluginNodeParser {
  static List<PluginNode> parseRoot(String jsonString) {
    final decoded = json.decode(jsonString) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception("Plugin API returned success=false");
    }

    if (decoded['data'] == null ||
        decoded['data'] is! Map ||
        decoded['data']['plugins'] == null) {
      throw Exception("Invalid plugin JSON: missing data.plugins[]");
    }

    final List<dynamic> pluginsJson = decoded['data']['plugins'];

    // Parse each plugin
    final List<PluginNode> nodes = pluginsJson
        .map((p) => _parseEnterprisePlugin(p as Map<String, dynamic>))
        .toList();

    // Register plugins globally so menus can resolve children
    PluginRegistry.registerAll(nodes);

    return nodes;
  }

  // ---------------------------------------------------------------------------
  // PARSE ENTERPRISE PLUGIN
  // ---------------------------------------------------------------------------
  static PluginNode _parseEnterprisePlugin(Map<String, dynamic> json) {
    final pluginId = json['plugin_id']?.toString() ?? '';
    final typeStr = json['type']?.toString().toLowerCase() ?? 'plugin';

    final bool isMenu = typeStr == 'menu';

    if (isMenu) {
      /// Menu node → only contains a list of child plugin IDs
      final List<String> childIds = [];

      final childrenJson = json['children'] as List<dynamic>? ?? [];
      for (final c in childrenJson) {
        if (c is Map<String, dynamic>) {
          final cid = c['plugin_id']?.toString();
          if (cid != null) childIds.add(cid);
        }
      }

      return PluginNode(
        pluginId: pluginId,
        name: json['name']?.toString() ?? pluginId,
        description: json['description']?.toString(),
        icon: json['icon']?.toString(),
        enabled: json['enabled'] == true || json['enabled'] == null,
        type: PluginNodeType.menu,
        childPluginIds: childIds,
        pluginConfig: null,
      );
    }

    // Plugin node → contains screens, actions, apis, metadata, routes
    final pluginConfig = <String, dynamic>{
      "plugin_id": pluginId,
      "name": json["name"],
      "routes": json["routes"] ?? [],
      "screens": json["screens"] ?? [],
      "actions": json["actions"] ?? [],
      "apis": json["apis"] ?? [],
      "metadata": json["metadata"] ?? {},
      "version": json["version"] ?? "1.0.0",
    };

    return PluginNode(
      pluginId: pluginId,
      name: json['name']?.toString() ?? pluginId,
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      enabled: true,
      type: PluginNodeType.plugin,
      childPluginIds: const [],
      pluginConfig: pluginConfig,
    );
  }
}
