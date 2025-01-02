import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _token = "";
  String _name = "";

  bool get isAuthenticated => _isAuthenticated;
  String get token => _token;
  String get name => _name;

  Future<void> login(String email, String password) async {
    final result = await AuthService.login(email, password);
    if (result['success']) {
      _isAuthenticated = true;
      _token = result['token'];
      _name = result['name']; // Lấy tên từ kết quả đăng nhập
      print('Token from AuthProvider: $_token'); // Log token để kiểm tra
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final result = await AuthService.register(name, email, password);
    if (result['success']) {
      _isAuthenticated = true;
      _token = result['token']; // Lưu token vào AuthProvider
    } else {
      _isAuthenticated = false;
      _token = "";
      throw Exception(result['message']);
    }
    notifyListeners();
  }


  void logout() {
    _isAuthenticated = false;
    _token = "";
    _name = "";
    print('User logged out.'); // Log để kiểm tra
    notifyListeners();
  }
}
