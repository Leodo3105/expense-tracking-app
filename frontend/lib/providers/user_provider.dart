import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  String _token = "";

  User? get currentUser => _currentUser;
  String get token => _token;

  // Đăng nhập và lưu trạng thái người dùng
  Future<void> login(String email, String password) async {
    final result = await UserService.login(email, password);
    if (result['success']) {
      _token = result['token'];
      _currentUser = await UserService.getCurrentUser(_token);
      notifyListeners();
    }
  }

  // Đăng ký và lưu trạng thái người dùng
  Future<void> register(String name, String email, String password) async {
    final result = await UserService.register(name, email, password);
    if (result['success']) {
      _token = result['token'];
      _currentUser = await UserService.getCurrentUser(_token);
      notifyListeners();
    }
  }

  // Đặt hạn mức chi tiêu
  Future<void> setSpendingLimit(double limit) async {
    if (_currentUser == null || _token.isEmpty) return;

    await UserService.setSpendingLimit(_token, limit);
    _currentUser = await UserService.getCurrentUser(_token);
    notifyListeners();
  }

  // Đăng xuất
  void logout() {
    _currentUser = null;
    _token = "";
    notifyListeners();
  }
}
