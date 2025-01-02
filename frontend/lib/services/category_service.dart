import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../utils/api_config.dart';

class CategoryService {
  // Fetch all categories
  static Future<List<Category>> getCategories(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/category/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception("Failed to fetch categories");
  }

  // Add a new category
  static Future<Category> addCategory(String name, String type, String token) async {
    final response = await http.post(
      Uri.parse('$apiUrl/category/add'),
      body: jsonEncode({'name': name, 'type': type}),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      // Log lỗi từ API
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception("Failed to add category");
    }
  }

  // Update an existing category
  static Future<void> updateCategory(int id, String name, String type, String token) async {
    final response = await http.put(
      Uri.parse('$apiUrl/category/update/$id'),
      body: jsonEncode({'name': name, 'type': type}),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update category");
    }
  }

  // Delete a category
  static Future<void> deleteCategory(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/category/delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete category");
    }
  }
}
