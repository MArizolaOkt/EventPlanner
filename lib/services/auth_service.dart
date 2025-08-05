// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final baseUrl = 'http://103.160.63.165/api';

  Future<http.Response> registerUserRawResponse({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      body: {
        'name': name,
        'email': email,
        'student_number': studentNumber,
        'major': major,
        'class_year': classYear.toString(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return response;
  }
}
