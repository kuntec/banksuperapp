import 'package:flutter/material.dart';
import 'package:superbankapp/screens/home_screen.dart';
import 'package:superbankapp/screens/login_screen.dart';
import 'package:superbankapp/services/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    final token = await SecureStorageService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Super Bank App"),
        ),
      ),
    );
  }
}
