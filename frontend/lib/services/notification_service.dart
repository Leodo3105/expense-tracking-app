import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificationmodel.dart';
import '../utils/api_config.dart';

class NotificationService {
  // Fetch all notifications
  static Future<List<NotificationModel>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/notification/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(int id, String token) async {
    final response = await http.put(
      Uri.parse('$apiUrl/notification/mark-as-read/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark notification as read");
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead(String token) async {
    final response = await http.put(
      Uri.parse('$apiUrl/notification/mark-all-as-read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark all notifications as read");
    }
  }
}
