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
    final success = apiJson['success']?.toString(); // from PLUGIN

    if (endpoint == null) return;

    final token = await SecureStorageService.getToken();
    if (token == null) throw Exception('No auth token');

    //final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
    //final uri = Uri.parse("http://localhost:8888/response.json");

    final uri = Uri.parse(endpoint);
    print("uri - ${uri}");
    final requestBody = _buildRequestBody(apiJson, nav);
    print(requestBody);
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
    print(response.body);
    // map response to context
    _applyResponseMapping(apiJson, decoded, nav);

    // handle navigation based on success/failure
    // final success = decoded['success'];
    final responseSuccess = decoded['success']; // from API RESPONSE
    final onSuccess = apiJson['on_success']?.toString();
    final onFailure = apiJson['on_failure']?.toString();
    print("API Success $responseSuccess");
    print("On Success $onSuccess");
    print("On Failure $onFailure");
    print("PLUGIN Success $success");

    if (success.toString() == responseSuccess.toString() && onSuccess != null) {
      nav.navigateTo(onSuccess);
    } else if (success.toString() != responseSuccess.toString() &&
        onFailure != null) {
      nav.navigateTo(onFailure);
    }

    // if (success && onSuccess != null) {
    //   print("On Success $onSuccess");
    //   nav.navigateTo(onSuccess);
    // } else if (!success && onFailure != null) {
    //   print("On Failure $onFailure");
    //   nav.navigateTo(onFailure);
    // }
  }

  static Map<String, dynamic> _buildRequestBody(
      Map<String, dynamic> apiJson, DynamicNavigationEngine nav) {
    final body = <String, dynamic>{};
    final mapping = apiJson['request_mapping'] as Map<String, dynamic>? ?? {};
    mapping.forEach((key, sourceKey) {
      print("Key : $key  value : $sourceKey");
      // sourceKey could be like "customer_id" (we keep it simple here)
      body[key] = nav.contextStore.getValue(sourceKey);
      print(nav.contextStore.getValue(sourceKey));
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
          print(current);
        } else {
          current = null;
          break;
        }
      }
      nav.contextStore.setValue(ctxKey, current);
    });
  }
}
