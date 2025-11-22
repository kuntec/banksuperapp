import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/dynamic_engine/screen_renderer.dart';

class DynamicPluginScreen extends StatefulWidget {
  final Map<String, dynamic> pluginConfig;
  DynamicPluginScreen({super.key, required this.pluginConfig});

  @override
  State<DynamicPluginScreen> createState() => _DynamicPluginScreenState();
}

class _DynamicPluginScreenState extends State<DynamicPluginScreen> {
  late DynamicNavigationEngine _navigation;

  @override
  void initState() {
    super.initState();
    _navigation = DynamicNavigationEngine(widget.pluginConfig);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _navigation.currentScreenId,
      builder: (context, screenId, _) {
        final screenJson = _navigation.getScreenJson(screenId);

        return Scaffold(
          appBar: AppBar(title: Text(screenJson['title'] ?? '')),
          body: DynamicScreenRenderer(
            screenJson: screenJson,
            navigation: _navigation,
          ),
        );
      },
    );
  }
}
