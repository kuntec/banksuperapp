import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbankapp/models/theme_config.dart';

class ThemeService extends ChangeNotifier {
  static const _cacheKey = 'remote_theme_json';
  static const _etagKey = 'remote_theme_etag';

  final String themeUrl; // e.g. https://api.example.com/config/theme.json

  ThemeConfig? _config;
  ThemeConfig? get config => _config;

  ThemeService({required this.themeUrl});

  Future<void> loadFromCacheThenServer() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Load cached immediately (fast startup)
    final cached = prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      _config = ThemeConfig.fromRaw(cached);
      notifyListeners();
    }

    // 2) Refresh from server (ETag-based)
    final etag = prefs.getString(_etagKey);
    final headers = <String, String>{};
    if (etag != null && etag.isNotEmpty) {
      headers['If-None-Match'] = etag;
    }

    final res = await http.get(Uri.parse(themeUrl), headers: headers);

    if (res.statusCode == 304) {
      // Not modified
      return;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body;
      _config = ThemeConfig.fromRaw(body);

      await prefs.setString(_cacheKey, body);

      final newEtag = res.headers['etag'];
      if (newEtag != null) {
        await prefs.setString(_etagKey, newEtag);
      }

      notifyListeners();
      return;
    }

    // If server fails, app continues with cached theme (no crash).
  }
}
