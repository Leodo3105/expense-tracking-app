import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../utils/api_config.dart';

class TransactionService {
  static Future<List<Transaction>> getTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/transaction/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Transaction> addTransaction(Transaction transaction, String token) async {
    final response = await http.post(
      Uri.parse('$apiUrl/transaction/add'),
      body: jsonEncode(transaction.toJson()),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to add transaction");
  }

  static Future<void> deleteTransaction(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/transaction/delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete transaction");
    }
  }
}
