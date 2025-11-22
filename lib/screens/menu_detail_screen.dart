import 'package:flutter/material.dart';
import 'package:superbankapp/models/plugin_node.dart';

class MenuDetailScreen extends StatefulWidget {
  final PluginNode menuNode;
  MenuDetailScreen({super.key, required this.menuNode});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plugin Menu"),
      ),
    );
  }
}
