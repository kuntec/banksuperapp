import 'package:superbankapp/core/app_config.dart';
import 'package:superbankapp/models/plugin_node.dart';
import 'package:superbankapp/models/plugin_node_parser.dart';
import 'package:superbankapp/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class PluginApiClient {
  Future<List<PluginNode>> fetchUserPlugins() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('No auth token');
    }

    // final uri = Uri.parse('${AppConfig.baseUrl}/api/plugins/my');
    final uri = Uri.parse('http://localhost:8888/BankPlugin.json');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load plugins: ${response.statusCode}');
    }

    return PluginNodeParser.parseRoot(response.body);
  }
}
