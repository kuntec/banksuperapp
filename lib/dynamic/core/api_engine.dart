// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import '../services/http_client.dart';
// import 'navigation_engine.dart';
// import 'action_engine.dart';
//
// class DynamicApiEngine {
//   static Future<void> executeApiById(
//     String apiId,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final apiJson = nav.getApiJson(apiId);
//     await executeApi(apiJson, nav, context);
//   }
//
//   static Future<void> executeApi(
//     Map<String, dynamic> apiJson,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final method = (apiJson['method'] ?? 'GET').toString().toUpperCase();
//     final url = apiJson['url']?.toString() ?? '';
//     final headers = <String, String>{'Content-Type': 'application/json'};
//
//     final extraHeaders = apiJson['headers'] as Map<String, dynamic>? ?? {};
//     extraHeaders.forEach((key, value) {
//       headers[key] = value.toString();
//     });
//
//     final body = _buildRequestBody(apiJson, nav);
//
//     http.Response response;
//     try {
//       if (method == 'GET') {
//         response = await HttpClientService.get(url, headers: headers);
//       } else {
//         response = await HttpClientService.post(
//           url,
//           headers: headers,
//           body: body,
//         );
//       }
//     } catch (_) {
//       final onFailure = apiJson['on_failure'] as Map<String, dynamic>?;
//       if (onFailure != null) {
//         await DynamicActionEngine.handle(onFailure, nav, context);
//       }
//       return;
//     }
//
//     Map<String, dynamic> decoded = {};
//     try {
//       decoded = jsonDecode(response.body) as Map<String, dynamic>;
//     } catch (_) {
//       decoded = {};
//     }
//
//     _applyResponseMapping(apiJson, decoded, nav);
//
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       final onSuccess = apiJson['on_success'] as Map<String, dynamic>?;
//       if (onSuccess != null) {
//         await DynamicActionEngine.handle(onSuccess, nav, context);
//       }
//     } else {
//       final onFailure = apiJson['on_failure'] as Map<String, dynamic>?;
//       if (onFailure != null) {
//         await DynamicActionEngine.handle(onFailure, nav, context);
//       }
//     }
//   }
//
//   static Map<String, dynamic> _buildRequestBody(
//     Map<String, dynamic> apiJson,
//     DynamicNavigationEngine nav,
//   ) {
//     final mapping = apiJson['request_mapping'] as Map<String, dynamic>? ?? {};
//     if (mapping.isEmpty) {
//       return nav.contextStore.getAll();
//     }
//
//     final Map<String, dynamic> body = {};
//     mapping.forEach((key, value) {
//       final val = value.toString();
//       if (val.startsWith('{{') && val.endsWith('}}')) {
//         final ctxKey = val.substring(2, val.length - 2);
//         body[key] = nav.contextStore.getValue(ctxKey);
//       } else {
//         body[key] = val;
//       }
//     });
//     return body;
//   }
//
//   static void _applyResponseMapping(
//     Map<String, dynamic> apiJson,
//     Map<String, dynamic> response,
//     DynamicNavigationEngine nav,
//   ) {
//     final mapping = apiJson['response_mapping'] as Map<String, dynamic>? ?? {};
//     mapping.forEach((key, path) {
//       final value = _extractByPath(response, path.toString());
//       nav.contextStore.setValue(key, value);
//     });
//   }
//
//   static dynamic _extractByPath(
//     Map<String, dynamic> json,
//     String path,
//   ) {
//     final parts = path.split('.');
//     dynamic current = json;
//     for (final p in parts) {
//       if (current is Map<String, dynamic> && current.containsKey(p)) {
//         current = current[p];
//       } else {
//         return null;
//       }
//     }
//     return current;
//   }
// }
