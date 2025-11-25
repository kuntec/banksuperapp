import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'context_store.dart';

class DynamicNavigationEngine {
  BuildContext? currentContext;

  /// Toggled whenever the screen should rebuild due to context changes.
  final ValueNotifier<bool> screenRefreshTrigger = ValueNotifier(false);

  /// The full plugin config JSON (for a single plugin/module).
  final Map<String, dynamic> pluginConfig;

  /// Current screen id.
  final ValueNotifier<String> currentScreenId;

  /// Shared context store for this plugin session.
  final DynamicContextStore contextStore = DynamicContextStore();

  DynamicNavigationEngine(this.pluginConfig)
      : currentScreenId = ValueNotifier<String>(
          _initialScreenIdFromConfig(pluginConfig),
        );

  /// Determine initial screen (simple version: first screen).
  static String _initialScreenIdFromConfig(Map<String, dynamic> pluginConfig) {
    // If you later add "routes" + default route, read from that.
    final screens = pluginConfig['screens'] as List<dynamic>? ?? const [];
    if (screens.isEmpty) {
      return 'unknown_screen';
    }
    final first = screens.first as Map<String, dynamic>;
    return first['screen_id']?.toString() ?? 'unknown_screen';
  }

  void attachContext(BuildContext ctx) {
    currentContext = ctx;
  }

  void notifyScreenRefresh() {
    screenRefreshTrigger.value = !screenRefreshTrigger.value;
  }

  void navigateTo(String screenId) {
    currentScreenId.value = screenId;
  }

  Map<String, dynamic> getScreenJson(String screenId) {
    final screens = pluginConfig['screens'] as List<dynamic>? ?? const [];
    return screens.firstWhere(
      (s) => (s as Map<String, dynamic>)['screen_id'] == screenId,
      orElse: () => <String, dynamic>{
        'screen_id': screenId,
        'title': 'Unknown screen: $screenId',
        'type': 'form',
        'fields': [],
        'actions': [],
      },
    ) as Map<String, dynamic>;
  }

  /// Get API definition by id.
  Map<String, dynamic> getApiJson(String apiId) {
    final apis = pluginConfig['apis'] as List<dynamic>? ?? const [];
    return apis.firstWhere(
      (a) {
        final api = a as Map<String, dynamic>;
        // Support both "id" and "api_id" keys for compatibility.
        return api['api_id']?.toString() == apiId ||
            api['id']?.toString() == apiId;
      },
      orElse: () => <String, dynamic>{
        'api_id': apiId,
        'method': 'GET',
        'endpoint': '',
      },
    ) as Map<String, dynamic>;
  }
}
