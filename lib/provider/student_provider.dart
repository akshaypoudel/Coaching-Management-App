import 'package:flutter/material.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> students = [];

  List<StudentModel> get getStudents => students;
  int get totalStudents => students.length;
  int get activeStudents =>
      students.where((e) => e.studentStatus == StudentStatus.Active).length;

  int get completedStudents => students.fold(
    0,
    (count, student) =>
        (student.studentStatus == StudentStatus.Completed) ? count + 1 : count,
  );

  double get totalFees =>
      students.fold(0, (sum, student) => sum + student.totalFees);

  double get totalFeesPaid =>
      students.fold(0, (sum, student) => sum + student.feesPaid);

  // double get totalFeesPaidThisMonth => students.fold(0, (sum, student) {
  //   if(student.)
  // });

  double get totalFeesDues =>
      students.fold(0, (sum, student) => sum + student.feesDues);

  List<StudentModel> get recentAdmissions {
    final sortedStudents = [...students];
    sortedStudents.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    return sortedStudents.take(5).toList();
  }

  List<double> get monthlyFeesCollection {
    List<double> monthlyTotals = List.filled(12, 0);
    for (var student in students) {
      final monthIndex = student.joiningDate.month - 1;
      monthlyTotals[monthIndex] += student.feesPaid;
    }
    return monthlyTotals;
  }

  Future<void> addStudent(StudentModel student) async {
    try {
      final newStudent = await ApiService.addStudent(student);

      students.add(newStudent);

      notifyListeners();

      // await loadStudents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadStudents() async {
    students = await ApiService.getStudents();
    notifyListeners();
  }

  /// DELETE STUDENT
  void deleteStudent(String id) {
    students.removeWhere((e) => e.rollNumber == id);
    notifyListeners();
  }

  /// UPDATE STUDENT
  void updateStudent(String rollNum, StudentModel updatedStudent) {
    final index = students.indexWhere((e) => e.rollNumber == rollNum);

    if (index != -1) {
      students[index] = updatedStudent;
      notifyListeners();
    }
  }

  /// FIND STUDENT
  StudentModel? getStudentById(String id) {
    try {
      return students.firstWhere((e) => e.rollNumber == id);
    } catch (e) {
      return null;
    }
  }
}
