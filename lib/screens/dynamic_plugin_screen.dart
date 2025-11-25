import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/dynamic_engine/screen_renderer.dart';

class DynamicPluginScreen extends StatefulWidget {
  final Map<String, dynamic> pluginConfig;

  const DynamicPluginScreen({
    super.key,
    required this.pluginConfig,
  });

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
    // Attach context so snackbars/dialogs can work from the engines
    _navigation.attachContext(context);

    return ValueListenableBuilder<String>(
      valueListenable: _navigation.currentScreenId,
      builder: (context, screenId, _) {
        final screenJson = _navigation.getScreenJson(screenId);

        return Scaffold(
            appBar: AppBar(
              title: Text(_resolveTitle(screenJson['title'])),
            ),

            // Rebuild when context-based labels / values change
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //     height: 100,
                  //     width: 200,
                  //     color: Colors.red,
                  //     child: Text(
                  //       _navigation.contextStore
                  //               .getValue("context.bill.customer_id") ??
                  //           "",
                  //       style: TextStyle(fontSize: 20),
                  //     )),
                  ValueListenableBuilder<bool>(
                    valueListenable: _navigation.screenRefreshTrigger,
                    builder: (context, __, ___) {
                      return DynamicScreenRenderer(
                        screenJson: screenJson,
                        navigation: _navigation,
                      );
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  /// Supports:
  /// - "Customer Details"
  /// - { "en": "Customer Details", "ar": "بيانات العميل" }
  String _resolveTitle(dynamic raw) {
    if (raw == null) return '';

    if (raw is String) return raw;

    if (raw is Map) {
      if (raw['en'] != null) return raw['en'].toString();
      if (raw.values.isNotEmpty) {
        final first = raw.values.first;
        if (first != null) return first.toString();
      }
    }

    return raw.toString();
  }
}
