import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keyToken = 'jwt_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  static Future<void> saveThirdPartyToken(String key, String token) async {
    await _storage.write(key: key, value: token);
  }

  static Future<String?> getThirdPartyToken(String key) async {
    return _storage.read(key: key);
  }
}
