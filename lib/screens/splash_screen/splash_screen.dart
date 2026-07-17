import 'package:flutter/material.dart';
import 'package:stdent_management_system/screens/bottom_navigation_bar.dart';
import 'package:stdent_management_system/screens/login/login_screen.dart';
import 'package:stdent_management_system/services/api_service.dart';
import 'package:stdent_management_system/services/app_initializer.dart';
import 'package:stdent_management_system/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final token = await StorageService.getToken();

    if (!mounted) return;

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final valid = await ApiService.verifyToken();

    if (!mounted) return;

    if (!valid) {
      await StorageService.logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

      return;
    }

    await AppInitializer.initialize(context);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomBottomNavigationBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
