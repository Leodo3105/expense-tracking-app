import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class StatisticService {
  // Lấy tổng quan thu nhập, chi tiêu, và số dư theo tháng
  static Future<Map<String, dynamic>> getMonthlyOverview(String token, int month, int year) async {
    final response = await http.get(
      Uri.parse('$apiUrl/statistic/monthly-overview?month=$month&year=$year'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch monthly overview");
    }
  }

  // Lấy tỷ lệ chi tiêu theo danh mục
  // static Future<List<Map<String, dynamic>>> getCategorySpendingRatio(String token, int month, int year) async {
  //   final response = await http.get(
  //     Uri.parse('$apiUrl/statistic/category-ratio?month=$month&year=$year'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  //   } else {
  //     throw Exception("Failed to fetch category spending ratio");
  //   }
  // }

}
