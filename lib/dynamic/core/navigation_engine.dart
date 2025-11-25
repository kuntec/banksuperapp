// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import '../context/context_store.dart';
// import '../errors/plugin_exceptions.dart';
// import 'widget_factory.dart';
// import 'action_engine.dart';
//
// class DynamicNavigationEngine {
//   final Map<String, dynamic> pluginConfig;
//   final DynamicContextStore contextStore = DynamicContextStore();
//   final ValueNotifier<String> currentScreenId;
//
//   DynamicNavigationEngine(this.pluginConfig)
//       : currentScreenId = ValueNotifier<String>(
//           _initialScreenId(pluginConfig),
//         );
//
//   static String _initialScreenId(Map<String, dynamic> pluginConfig) {
//     final screens = pluginConfig['screens'] as List<dynamic>? ?? [];
//     if (screens.isEmpty) {
//       throw PluginException('Plugin has no screens defined');
//     }
//     return (screens.first as Map<String, dynamic>)['screen_id'] as String;
//   }
//
//   List<dynamic> get screens => pluginConfig['screens'] as List<dynamic>? ?? [];
//   List<dynamic> get apis => pluginConfig['apis'] as List<dynamic>? ?? [];
//
//   Map<String, dynamic> getScreenJson(String screenId) {
//     return screens.firstWhere(
//       (s) => s['screen_id'] == screenId,
//       orElse: () => screens.first,
//     ) as Map<String, dynamic>;
//   }
//
//   Map<String, dynamic> getApiJson(String apiId) {
//     return apis.firstWhere(
//       (a) => a['api_id'] == apiId,
//       orElse: () => throw PluginException('API not found: $apiId'),
//     ) as Map<String, dynamic>;
//   }
//
//   void navigateTo(String screenId, {Map<String, dynamic>? params}) {
//     params?.forEach((k, v) => contextStore.setValue(k, v));
//     currentScreenId.value = screenId;
//   }
//
//   Future<void> runPreloadForScreen(
//     String screenId,
//     BuildContext context,
//   ) async {
//     final screenJson = getScreenJson(screenId);
//     if (screenJson.containsKey('preload')) {
//       final preloadAction = screenJson['preload'] as Map<String, dynamic>;
//       await DynamicActionEngine.handle(preloadAction, this, context);
//     }
//   }
//
//   Widget buildScreen(BuildContext context) {
//     return ValueListenableBuilder<String>(
//       valueListenable: currentScreenId,
//       builder: (context, screenId, _) {
//         WidgetsBinding.instance.addPostFrameCallback((_) async {
//           await runPreloadForScreen(screenId, context);
//         });
//
//         final screenJson = getScreenJson(screenId);
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(
//               screenJson['title']?.toString() ??
//                   pluginConfig['name'] ??
//                   'Plugin',
//             ),
//           ),
//           body: WidgetFactory.buildScreenBody(screenJson, this, context),
//         );
//       },
//     );
//   }
// }
