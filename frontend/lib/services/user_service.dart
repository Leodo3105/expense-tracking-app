import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_config.dart';

class UserService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'token': jsonDecode(response.body)['token']};
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
      return {'success': true, 'token': jsonDecode(response.body)['token']};
    }
    return {'success': false};
  }

  static Future<User> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch user");
  }

  static Future<void> setSpendingLimit(String token, double limit) async {
    final response = await http.put(
      Uri.parse('$apiUrl/user/spending-limit'),
      body: jsonEncode({'spendingLimit': limit}),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update spending limit");
    }
  }
}
