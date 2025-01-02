import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  String _token = "";

  List<Category> get categories => _categories;
  String get token => _token;

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  // Fetch all categories
  Future<void> fetchCategories() async {
    _categories = await CategoryService.getCategories(_token);
    notifyListeners();
  }

  // Add a new category
  Future<void> addCategory(String name, String type) async {
    final newCategory = await CategoryService.addCategory(name, type, _token);
    _categories.add(newCategory);
    notifyListeners();
  }

  // Update an existing category
  Future<void> updateCategory(int id, String name, String type) async {
    await CategoryService.updateCategory(id, name, type, _token);
    final categoryIndex = _categories.indexWhere((category) => category.id == id);
    if (categoryIndex >= 0) {
      final existingCategory = _categories[categoryIndex];
      _categories[categoryIndex] = Category(
        id: id,
        name: name,
        type: type,
        userId: existingCategory.userId,
      );
      notifyListeners();
    }
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    await CategoryService.deleteCategory(id, _token);
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }
}
