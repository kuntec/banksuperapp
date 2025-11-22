import 'package:superbankapp/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:superbankapp/services/secure_storage_service.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      return false;
    }
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true && decoded['data']['token'] != null) {
      await SecureStorageService.saveToken(decoded['data']['token']);
      return true;
    }
    return false;
  }
}
