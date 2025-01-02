import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recurringtransaction.dart';
import '../utils/api_config.dart';

class RecurringTransactionService {
  // Fetch all recurring transactions
  static Future<List<RecurringTransaction>> getRecurringTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/recurring-transaction/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) { // Đổi từ 201 thành 200
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => RecurringTransaction.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load recurring transactions');
    }
  }


  // Add a recurring transaction
  static Future<RecurringTransaction> addRecurringTransaction(
      RecurringTransaction transaction, String token) async {
    final response = await http.post(
      Uri.parse('$apiUrl/recurring-transaction/add'),
      body: jsonEncode(transaction.toJson()),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        return RecurringTransaction.fromJson(responseBody['data']);
      }
    }

    throw Exception("Failed to add recurring transaction");
  }


  // Delete a recurring transaction
  static Future<void> deleteRecurringTransaction(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/recurring-transaction/delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete recurring transaction");
    }
  }
}
