import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/recurringtransaction.dart';
import '../services/transaction_service.dart';
import '../services/recurring_transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<RecurringTransaction> _recurringTransactions = [];
  String _token = "";

  List<Transaction> get transactions => _transactions;
  List<RecurringTransaction> get recurringTransactions => _recurringTransactions;
  String get token => _token;

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  // Fetch all transactions
  Future<void> fetchTransactions() async {
    _transactions = await TransactionService.getTransactions(_token);
    notifyListeners();
  }

  // Add a transaction
  Future<void> addTransaction(Transaction transaction) async {
    final newTransaction = await TransactionService.addTransaction(transaction, _token);
    _transactions.add(newTransaction);
    notifyListeners();
  }

  // Delete a transaction
  Future<void> deleteTransaction(int id) async {
    await TransactionService.deleteTransaction(id, _token);
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  // Fetch recurring transactions
  Future<void> fetchRecurringTransactions() async {
    _recurringTransactions = await RecurringTransactionService.getRecurringTransactions(_token);
    notifyListeners();
  }

  // Add a recurring transaction
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    final newRecurringTransaction = await RecurringTransactionService.addRecurringTransaction(transaction, _token);
    _recurringTransactions.add(newRecurringTransaction);
    notifyListeners();
  }

  // Delete a recurring transaction
  Future<void> deleteRecurringTransaction(int id) async {
    await RecurringTransactionService.deleteRecurringTransaction(id, _token);
    _recurringTransactions.removeWhere((recurring) => recurring.id == id);
    notifyListeners();
  }
}
