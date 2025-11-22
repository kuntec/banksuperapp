import 'package:flutter/material.dart';

class DynamicPluginScreen extends StatefulWidget {
  final Map<String, dynamic> pluginConfig;
  DynamicPluginScreen({super.key, required this.pluginConfig});

  @override
  State<DynamicPluginScreen> createState() => _DynamicPluginScreenState();
}

class _DynamicPluginScreenState extends State<DynamicPluginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dynamic Plugin Screen"),
      ),
    );
  }
}
