import 'package:flutter/material.dart';
import 'package:superbankapp/models/plugin_node.dart';
import 'package:superbankapp/screens/dynamic_plugin_screen.dart';
import 'package:superbankapp/screens/login_screen.dart';
import 'package:superbankapp/screens/menu_detail_screen.dart';
import 'package:superbankapp/services/plugin_loader.dart';
import 'package:superbankapp/services/secure_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _loader = PluginLoader();
  late Future<List<PluginNode>> _futureNodes;

  @override
  void initState() {
    super.initState();
    _futureNodes = _loader.loadUserPlugins();
  }

  Future<void> _logout() async {
    await SecureStorageService.clearToken();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        // backgroundColor: Colors.blue,
        title: const Text(
          'Banking Super App',
        ),
        actions: [IconButton(onPressed: _logout, icon: Icon(Icons.logout))],
      ),
      body: FutureBuilder<List<PluginNode>>(
        future: _futureNodes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final nodes = snapshot.data ?? [];

          if (nodes.isEmpty) {
            return const Center(child: Text('No plugins available'));
          }

          return ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];

              if (node.type == PluginNodeType.menu) {
                return ListTile(
                  leading: const Icon(Icons.menu),
                  title: Text(node.name),
                  subtitle: Text(node.description ?? 'Menu'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuDetailScreen(menuNode: node),
                      ),
                    );
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.extension),
                  title: Text(node.name),
                  subtitle: Text(node.description ?? 'Plugin'),
                  onTap: () {
                    if (node.pluginConfig == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DynamicPluginScreen(
                            pluginConfig: node.pluginConfig!),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
