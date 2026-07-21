import 'package:flutter/material.dart';
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> students = [];

  List<StudentModel> get getStudents => students;

  List<StudentModel> _students = [];

  List<StudentModel> _filteredStudents = [];

  int get totalStudents => students.length;

  int get activeStudents =>
      students.where((e) => e.studentStatus == StudentStatus.Active).length;

  int get completedStudents => students.fold(
    0,
    (count, student) =>
        (student.studentStatus == StudentStatus.Completed) ? count + 1 : count,
  );

  int get studentThisMonth {
    final now = DateTime.now();
    return students.where((student) {
      return student.joiningDate.month == now.month &&
          student.joiningDate.year == now.year;
    }).length;
  }

  double get thisMonthCollection {
    final now = DateTime.now();

    double total = 0;

    for (final student in students) {
      for (final payment in student.payments) {
        if (payment.paymentDate.month == now.month &&
            payment.paymentDate.year == now.year) {
          total += payment.amount;
        }
      }
    }

    return total;
  }

  double get lastMonthCollection {
    final now = DateTime.now();

    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;

    double total = 0;

    for (final student in students) {
      for (final payment in student.payments) {
        if (payment.paymentDate.month == previousMonth &&
            payment.paymentDate.year == previousYear) {
          total += payment.amount;
        }
      }
    }

    return total;
  }

  double get collectionGrowthPercentage {
    if (lastMonthCollection == 0) {
      return 0;
    }

    return ((thisMonthCollection - lastMonthCollection) / lastMonthCollection) *
        100;
  }

  int get studentsWithPendingFees {
    return students
        .where((student) => student.feeStatus == FeesStatus.Due)
        .length;
  }

  bool get isCollectionGrowing => collectionGrowthPercentage >= 0;

  double get totalFees =>
      students.fold(0, (sum, student) => sum + student.totalFees);

  double get totalFeesPaid =>
      students.fold(0, (sum, student) => sum + student.feesPaid);

  double get collectionPercentage {
    if (totalFees == 0) return 0;
    return (totalFeesPaid / totalFees) * 100;
  }

  double get overdueAmount {
    final today = DateTime.now();

    return students
        .where((student) {
          final dueDate = student.joiningDate.add(const Duration(days: 30));

          return student.feesDues > 0 && today.isAfter(dueDate);
        })
        .fold(0, (sum, student) => sum + student.feesDues);
  }

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
    _students = await ApiService.getStudents();

    _filteredStudents = List.from(_students);
    notifyListeners();
  }

  void searchStudents(String query) {
    if (query.trim().isEmpty) {
      _filteredStudents = List.from(_students);
    } else {
      final search = query.toLowerCase();

      _filteredStudents = _students.where((student) {
        return student.name.toLowerCase().contains(search) ||
            student.course.toLowerCase().contains(search) ||
            student.rollNumber.toLowerCase().contains(search) ||
            student.phone.toLowerCase().contains(search);
      }).toList();
    }

    notifyListeners();
  }

  void deleteStudent(String id) {
    students.removeWhere((e) => e.rollNumber == id);
    notifyListeners();
  }

  Future<void> updateStudent(
    String rollNum,
    StudentModel updatedStudent,
  ) async {}

  StudentModel? getStudentById(String id) {
    try {
      return students.firstWhere((e) => e.rollNumber == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> collectFees(FeePayment payment) async {
    await ApiService.collectFee(payment: payment);
    await loadStudents();
  }
}
