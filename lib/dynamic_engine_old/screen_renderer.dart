import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/dynamic_engine/widget_factory.dart';

class DynamicScreenRenderer extends StatelessWidget {
  final Map<String, dynamic> screenJson;
  final DynamicNavigationEngine navigation;

  const DynamicScreenRenderer({
    super.key,
    required this.screenJson,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    final fields = screenJson['fields'] as List<dynamic>? ?? [];
    final actions = screenJson['actions'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WidgetFactory.buildField(
                field as Map<String, dynamic>,
                navigation.contextStore,
              ),
            ),
          const SizedBox(height: 20),
          for (var action in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WidgetFactory.buildAction(
                action as Map<String, dynamic>,
                navigation,
              ),
            ),
        ],
      ),
    );
  }
}
