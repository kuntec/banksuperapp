import 'package:flutter/material.dart';
import 'package:superbankapp/screens/login_screen.dart';
import 'package:superbankapp/services/secure_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    await SecureStorageService.clearToken();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Home"),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: Icon(
                Icons.power_settings_new_outlined,
                size: 30,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [Text("Homepage")],
        ),
      ),
    );
  }
}
