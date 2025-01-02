import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return {
        'success': true,
        'token': responseBody['token'],
        'name': responseBody['name'], // Thêm tên người dùng
      };
    }
    return {'success': false};
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/register'),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return {
        'success': true,
        'token': responseBody['token'], // Lấy token từ phản hồi
      };
    } else {
      final responseBody = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseBody['error'] ?? 'Unknown error occurred'
      };
    }
  }

}
