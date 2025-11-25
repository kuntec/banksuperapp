import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'context_store.dart';

class DynamicNavigationEngine {
  BuildContext? currentContext;
  final ValueNotifier<bool> screenRefreshTrigger = ValueNotifier(false);
  final Map<String, dynamic> pluginConfig;
  final ValueNotifier<String> currentScreenId;
  final DynamicContextStore contextStore = DynamicContextStore();

  DynamicNavigationEngine(this.pluginConfig)
      : currentScreenId = ValueNotifier(
          (pluginConfig['screens'] as List).first['screen_id'],
        );

  void registerContext(BuildContext ctx) {
    currentContext = ctx;
  }

  void notifyScreenRefresh() {
    screenRefreshTrigger.value = !screenRefreshTrigger.value;
  }

  void navigateTo(String screenId) {
    currentScreenId.value = screenId;
  }

  Map<String, dynamic> getScreenJson(String screenId) {
    final screens = pluginConfig['screens'] as List<dynamic>;
    return screens.firstWhere((s) => s['screen_id'] == screenId);
  }

  Map<String, dynamic> getApiJson(String apiId) {
    final apis = pluginConfig['apis'] as List<dynamic>;
    return apis.firstWhere((a) => a['id'] == apiId);
  }
}
