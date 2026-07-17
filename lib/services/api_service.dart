import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stdent_management_system/model/student_model.dart';
import 'package:stdent_management_system/services/storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: "token");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  static Future<bool> verifyToken() async {
    final token = await StorageService.getToken();

    if (token == null) return false;

    final response = await http.get(
      Uri.parse("$baseUrl/verify-token"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }

  static Future<List<StudentModel>> getStudents() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/students"),

      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    return data.map<StudentModel>((e) => StudentModel.fromJson(e)).toList();
  }

  static Future<StudentModel> addStudent(StudentModel student) async {
    final response = await http.post(
      Uri.parse("$baseUrl/students"),
      headers: await _authHeaders(),
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentModel.fromJson(jsonDecode(response.body));
    }
    log('asldkjfa;lsdjf;lkasjd;flkajsdl;kf');
    throw Exception(jsonDecode(response.body)["detail"]);
  }
}
