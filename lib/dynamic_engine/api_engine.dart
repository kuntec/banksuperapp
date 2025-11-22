import 'package:superbankapp/core/app_config.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DynamicApiEngine {
  static Future<void> executeApi(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final apiId = action['api_id']?.toString();
    if (apiId == null) return;

    final apiJson = nav.getApiJson(apiId);

    final endpoint = apiJson['endpoint']?.toString();
    final method = (apiJson['method'] ?? 'POST').toString().toUpperCase();

    if (endpoint == null) return;

    final token = await SecureStorageService.getToken();
    if (token == null) throw Exception('No auth token');

    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

    final requestBody = _buildRequestBody(apiJson, nav);

    http.Response response;
    if (method == 'GET') {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } else {
      response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
    }

    final decoded = jsonDecode(response.body);

    // map response to context
    _applyResponseMapping(apiJson, decoded, nav);

    // handle navigation based on success/failure
    final success = decoded['success'] == true;
    final onSuccess = apiJson['on_success']?.toString();
    final onFailure = apiJson['on_failure']?.toString();

    if (success && onSuccess != null) {
      nav.navigateTo(onSuccess);
    } else if (!success && onFailure != null) {
      nav.navigateTo(onFailure);
    }
  }

  static Map<String, dynamic> _buildRequestBody(
      Map<String, dynamic> apiJson, DynamicNavigationEngine nav) {
    final body = <String, dynamic>{};

    final mapping = apiJson['request_mapping'] as Map<String, dynamic>? ?? {};

    mapping.forEach((key, sourceKey) {
      // sourceKey could be like "customer_id" (we keep it simple here)
      body[key] = nav.contextStore.getValue(sourceKey);
    });

    return body;
  }

  static void _applyResponseMapping(Map<String, dynamic> apiJson,
      Map<String, dynamic> response, DynamicNavigationEngine nav) {
    final mapping = apiJson['response_mapping'] as Map<String, dynamic>? ?? {};

    mapping.forEach((ctxKey, responsePath) {
      final path = responsePath.toString().split('.');
      dynamic current = response;
      for (final p in path) {
        if (current is Map<String, dynamic> && current.containsKey(p)) {
          current = current[p];
        } else {
          current = null;
          break;
        }
      }
      nav.contextStore.setValue(ctxKey, current);
    });
  }
}
