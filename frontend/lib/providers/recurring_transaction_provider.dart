import 'package:flutter/material.dart';
import '../models/recurringtransaction.dart';
import '../services/recurring_transaction_service.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  List<RecurringTransaction> _recurringTransactions = [];
  String _token = "";

  List<RecurringTransaction> get recurringTransactions => _recurringTransactions;
  String get token => _token;

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  // Fetch all recurring transactions
  Future<void> fetchRecurringTransactions() async {
    try {
      _recurringTransactions = await RecurringTransactionService.getRecurringTransactions(_token);
      notifyListeners();
    } catch (error) {
      print('Error fetching recurring transactions: $error');
      throw Exception('Failed to fetch recurring transactions');
    }
  }

  // Add a recurring transaction
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      final newTransaction = await RecurringTransactionService.addRecurringTransaction(transaction, _token);
      _recurringTransactions.add(newTransaction);
      notifyListeners();
      print('Recurring transaction added successfully.');
    } catch (error) {
      print('Error adding recurring transaction: $error');
      throw Exception('Failed to add recurring transaction: $error');
    }
  }

  // Delete a recurring transaction
  Future<void> deleteRecurringTransaction(int id) async {
    await RecurringTransactionService.deleteRecurringTransaction(id, _token);
    _recurringTransactions.removeWhere((recurring) => recurring.id == id);
    notifyListeners();
  }
}
