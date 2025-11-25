// import 'package:flutter/material.dart';
// import 'package:superbankapp/models/plugin_node.dart';
// import 'package:superbankapp/screens/dynamic_plugin_screen.dart';
//
// class MenuDetailScreen extends StatelessWidget {
//   final PluginNode menuNode;
//   const MenuDetailScreen({super.key, required this.menuNode});
//
//   @override
//   Widget build(BuildContext context) {
//     final children = menuNode.children;
//
//     return Scaffold(
//       appBar: AppBar(title: Text(menuNode.name)),
//       body: ListView.builder(
//         itemCount: children.length,
//         itemBuilder: (context, index) {
//           final node = children[index];
//
//           return ListTile(
//             leading: const Icon(Icons.extension),
//             title: Text(node.name),
//             onTap: () {
//               if (node.pluginConfig == null) return;
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       DynamicPluginScreen(pluginConfig: node.pluginConfig!),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:superbankapp/models/plugin_node.dart';
import 'package:superbankapp/models/plugin_registry.dart';
import 'package:superbankapp/screens/dynamic_plugin_screen.dart';

class MenuDetailScreen extends StatelessWidget {
  final PluginNode menuNode;

  const MenuDetailScreen({super.key, required this.menuNode});

  @override
  Widget build(BuildContext context) {
    // New enterprise structure uses childPluginIds (list of String IDs)
    final List<String> childIds = menuNode.childPluginIds;

    return Scaffold(
      appBar: AppBar(title: Text(menuNode.name)),
      body: ListView.builder(
        itemCount: childIds.length,
        itemBuilder: (context, index) {
          final pluginId = childIds[index];

          // Fetch real plugin node from registry
          final node = PluginRegistry.get(pluginId);
          if (node == null) {
            return ListTile(
              title: Text("Unknown plugin: $pluginId"),
              leading: const Icon(Icons.warning),
            );
          }

          return ListTile(
            leading: const Icon(Icons.extension),
            title: Text(node.name),
            onTap: () {
              if (node.pluginConfig == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DynamicPluginScreen(
                    pluginConfig: node.pluginConfig!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
