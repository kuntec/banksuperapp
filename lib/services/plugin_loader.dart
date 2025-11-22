import '../models/plugin_node.dart';
import 'plugin_api_client.dart';

class PluginLoader {
  final PluginApiClient _apiClient = PluginApiClient();

  Future<List<PluginNode>> loadUserPlugins() async {
    final nodes = await _apiClient.fetchUserPlugins();
    return nodes.where((n) => n.enabled).toList();
  }
}
