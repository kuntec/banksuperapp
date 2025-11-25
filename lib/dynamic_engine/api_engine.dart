import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:superbankapp/core/app_config.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/services/secure_storage_service.dart';

class DynamicApiEngine {
  /// Execute API for a given action:
  /// action must contain "api_id".
  ///
  /// It will:
  ///  - find the API definition in pluginConfig['apis']
  ///  - build headers and body using request_mapping + context
  ///  - call HTTP
  ///  - apply response_mapping into context
  ///
  /// It does *not* navigate; that is handled by the ActionEngine.
  static Future<void> executeApi(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final apiId = action['api_id']?.toString();
    if (apiId == null) return;

    final apiJson = nav.getApiJson(apiId);

    final rawEndpoint = apiJson['endpoint']?.toString() ?? '';
    if (rawEndpoint.isEmpty) return;

    final method = (apiJson['method'] ?? 'POST').toString().toUpperCase();

    // Build URI (support absolute or relative to AppConfig.baseUrl)
    late final Uri uri;
    if (rawEndpoint.startsWith('http://') ||
        rawEndpoint.startsWith('https://')) {
      uri = Uri.parse(rawEndpoint);
    } else {
      uri = Uri.parse('${AppConfig.baseUrl}$rawEndpoint');
    }
    print("URI $uri");

    // Build headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final apiHeaders = apiJson['headers'];
    if (apiHeaders is Map<String, dynamic>) {
      apiHeaders.forEach((k, v) {
        var value = v?.toString() ?? '';
        // Support context placeholders: "Bearer {{context.payment.auth_token}}"
        final regex = RegExp(r'\{\{([^}]+)\}\}');
        value = value.replaceAllMapped(regex, (match) {
          final path = match.group(1)?.trim() ?? '';
          final ctxVal = nav.contextStore.getValue(path);
          return ctxVal?.toString() ?? '';
        });
        headers[k] = value;
      });
    }

    // Attach main JWT token if available (unless already present)
    if (!headers.containsKey('Authorization')) {
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Build body from request_mapping
    Map<String, dynamic> body = {};
    final reqMap = apiJson['request_mapping'];
    if (reqMap is Map<String, dynamic>) {
      reqMap.forEach((paramName, sourceSpec) {
        if (sourceSpec == null) return;
        if (sourceSpec is String) {
          dynamic value;

          // If looks like a context path or has dot -> read from context.
          if (sourceSpec.startsWith('context.') || sourceSpec.contains('.')) {
            value = nav.contextStore.getValue(sourceSpec);
          } else {
            // Try context by key (like "email" -> context["email"])
            value = nav.contextStore.getValue(sourceSpec);
            // If still null, treat as literal constant.
            value ??= sourceSpec;
          }
          body[paramName] = value;
        } else {
          // Literal value from JSON
          body[paramName] = sourceSpec;
        }
      });
    }
    print(body.toString());
    http.Response response;
    try {
      if (method == 'GET') {
        // For GET we ignore body currently (can be extended to query params)
        response = await http.get(uri, headers: headers);
      } else {
        response = await http.post(
          uri,
          headers: headers,
          body: json.encode(body),
        );
      }
    } catch (e) {
      // Network or other error - store error and rethrow to let ActionEngine
      nav.contextStore.setValue('context.last_error', e.toString());
      rethrow;
    }

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (_) {
      decoded = response.body;
    }

// Store entire raw response
    nav.contextStore.setValue('context.last_response', decoded);

// ⚠️ BUSINESS FAILURE CHECK HERE
    bool jsonSuccess = true;

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('success') && decoded['success'] == false) {
        jsonSuccess = false;

        // capture error if exists
        final errorMsg = decoded['error']?.toString() ?? 'Unknown API error';
        nav.contextStore.setValue('context.last_error', errorMsg);

        // throw to trigger ActionEngine.on_failure
        throw Exception('API business failure: $errorMsg');
      }
    }

// Apply response_mapping normally if success
    final resMap = apiJson['response_mapping'];
    if (decoded != null && resMap is Map<String, dynamic>) {
      resMap.forEach((ctxKey, responsePath) {
        if (responsePath == null) return;
        if (responsePath is! String) {
          nav.contextStore.setValue(ctxKey.toString(), responsePath);
          return;
        }

        final path = responsePath.split('.');
        dynamic current = decoded;
        for (final p in path) {
          if (current is Map<String, dynamic> && current.containsKey(p)) {
            current = current[p];
          } else {
            current = null;
            break;
          }
        }
        nav.contextStore.setValue(ctxKey.toString(), current);
      });
    }
  }
}
