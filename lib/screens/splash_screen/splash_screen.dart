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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffF7F9FF), Color(0xffEEF3FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Illustration
              Image.asset("assets/images/splash.png", height: 230),

              const SizedBox(height: 40),

              const Text(
                "DeityCoach",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xff1E293B),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Smart Institute Management Platform",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),

              const Spacer(),

              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xff4F46E5),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Loading...",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
