import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stdent_management_system/screens/bottom_navigation_bar.dart';

import 'package:stdent_management_system/screens/login/colors.dart';
import 'package:stdent_management_system/screens/login/app_textstyles.dart';
import 'package:stdent_management_system/screens/login/custom_button.dart';
import 'package:stdent_management_system/screens/login/custom_textfield.dart';
import 'package:stdent_management_system/services/api_service.dart';
import 'package:stdent_management_system/services/app_initializer.dart';
import 'package:stdent_management_system/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 40),

                const Text("Welcome Back 👋", style: AppTextStyles.heading),

                const SizedBox(height: 10),

                const Text(
                  "Sign in to continue",
                  style: AppTextStyles.subtitle,
                ),

                const SizedBox(height: 40),

                CustomTextField(
                  controller: usernameController,
                  hint: "Email",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),

                const SizedBox(height: 14),

                Align(
                  alignment: Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {},

                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 10),

                CustomButton(
                  title: "Log In",
                  onPressed: () async {
                    await checkLogin();
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkLogin() async {
    try {
      final response = await ApiService.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      await StorageService.saveToken(response["token"]);
      await AppInitializer.initialize(context);

      if (!mounted) return;
      log(response.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomBottomNavigationBar()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
