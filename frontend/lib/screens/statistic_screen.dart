import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistic_provider.dart';

class StatisticScreen extends StatefulWidget {
  final int currentMonth;
  final int currentYear;

  StatisticScreen({required this.currentMonth, required this.currentYear});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final statisticProvider =
    Provider.of<StatisticProvider>(context, listen: false);

    // Tải dữ liệu ban đầu
    await statisticProvider.loadInitialData();
    // Lọc dữ liệu theo tháng và năm
    statisticProvider.filterTransactionsByMonth(
        widget.currentMonth, widget.currentYear);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statisticProvider = Provider.of<StatisticProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hiển thị tổng quan
            _buildOverviewSection(statisticProvider),
            SizedBox(height: 24),
            // Hiển thị chi tiết thu nhập và chi tiêu
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionDetails(
                    "Income Details",
                    statisticProvider.categoryIncome,
                    Colors.greenAccent, // Màu xanh lá nhạt
                  ),
                  SizedBox(height: 16),
                  _buildTransactionDetails(
                    "Expense Details",
                    statisticProvider.categoryExpense,
                    Colors.orangeAccent, // Màu cam nhạt
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị tổng quan
  Widget _buildOverviewSection(StatisticProvider statisticProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistics for Month ${widget.currentMonth} / ${widget.currentYear}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatisticItem("Income", "\$${statisticProvider.totalIncome}", Colors.greenAccent),
                _buildStatisticItem("Expense", "\$${statisticProvider.totalExpense}", Colors.orangeAccent),
                _buildStatisticItem("Balance", "\$${statisticProvider.balance}", Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị một mục thống kê
  Widget _buildStatisticItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black, // Màu đen cho số tiền
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Hiển thị chi tiết giao dịch
  Widget _buildTransactionDetails(
      String title, Map<String, double> transactions, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  color == Colors.greenAccent ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...transactions.entries.map((entry) {
              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    color == Colors.greenAccent ? Icons.trending_up : Icons.trending_down,
                    color: color,
                    size: 20,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Text(
                  "\$${entry.value.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.black, // Màu đen cho số tiền
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}