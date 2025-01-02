import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/category_service.dart';
import '../services/statistic_service.dart';
import '../services/transaction_service.dart';

class StatisticProvider extends ChangeNotifier {
  // Tổng quan thu nhập, chi tiêu, và số dư
  int totalIncome = 0;
  int totalExpense = 0;
  int balance = 0;
  bool isLoading = false;

  // Giao dịch nhóm theo thu nhập và chi tiêu
  Map<String, double> categoryIncome = {};
  Map<String, double> categoryExpense = {};
  List<Transaction> allTransactions = [];
  List<Category> categories = [];

  // Tỷ lệ chi tiêu theo danh mục
  List<Map<String, dynamic>> categoryRatios = [];

  // Xu hướng chi tiêu hàng tháng
  List<Map<String, dynamic>> monthlyTrend = [];

  String _token = "";

  String get token => _token;

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  // Tải dữ liệu giao dịch và danh mục
  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();

    try {
      allTransactions = await TransactionService.getTransactions(_token);
      categories = await CategoryService.getCategories(_token);
    } catch (error) {
      print("Error loading initial data: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lọc giao dịch theo tháng và năm, đồng thời nhóm theo danh mục
  void filterTransactionsByMonth(int month, int year) {
    // Lọc giao dịch theo tháng và năm
    final filteredTransactions = allTransactions.where((transaction) {
      final transactionDate = transaction.date; // Assumes `date` is DateTime
      return transactionDate.month == month && transactionDate.year == year;
    }).toList();

    // Reset tổng số liệu
    categoryIncome = {};
    categoryExpense = {};
    totalIncome = 0;
    totalExpense = 0;

    // Phân loại giao dịch theo danh mục
    for (var transaction in filteredTransactions) {
      final category = categories.firstWhere(
            (cat) => cat.id == transaction.categoryId,
        orElse: () => Category(id: 0, name: 'Unknown', type: 'unknown', userId: 0),
      );

      if (category.type == 'income') {
        totalIncome += transaction.amount.toInt();
        categoryIncome[category.name] =
            (categoryIncome[category.name] ?? 0) + transaction.amount;
      } else if (category.type == 'expense') {
        totalExpense += transaction.amount.toInt();
        categoryExpense[category.name] =
            (categoryExpense[category.name] ?? 0) + transaction.amount;
      }
    }

    // Cập nhật số dư
    balance = totalIncome - totalExpense;
    notifyListeners();
  }

  // Lấy tổng quan thu nhập và chi tiêu theo tháng
  Future<void> fetchMonthlyOverview(int month, int year) async {
    isLoading = true;
    notifyListeners();

    try {
      final overview = await StatisticService.getMonthlyOverview(_token, month, year);
      totalIncome = (overview['totalIncome'] ?? 0);
      totalExpense = (overview['totalExpense'] ?? 0);
      balance = (overview['balance'] ?? 0);
    } catch (error) {
      print("Error fetching monthly overview: $error");
      totalIncome = 0;
      totalExpense = 0;
      balance = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // Lấy tỷ lệ chi tiêu theo danh mục
  // Future<void> fetchCategoryRatios(int month, int year) async {
  //   categoryRatios = await StatisticService.getCategorySpendingRatio(_token, month, year);
  //   notifyListeners();
  // }

}
