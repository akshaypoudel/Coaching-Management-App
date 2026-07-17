import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:stdent_management_system/provider/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/screens/login/login_screen.dart';
import 'package:stdent_management_system/screens/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => StudentProvider())],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Management System',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.purple)),
        home: SplashScreen(),
      ),
    );
  }
}
