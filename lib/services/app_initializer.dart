import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stdent_management_system/provider/student_provider.dart';

class AppInitializer {
  static Future<void> initialize(BuildContext context) async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      studentProvider.loadStudents(),
      // courseProvider.loadCourses(),
      // attendanceProvider.loadAttendance(),
      // dashboardProvider.loadDashboard(),
    ]);
  }
}
