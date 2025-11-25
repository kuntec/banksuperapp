import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClientService {
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) {
    return http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
  }
}
