import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/screens/statistic_screen.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/recurring_transaction_provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future<void> _loadDataFuture;
  int _selectedIndex = 0; // Chỉ số của item được chọn trong BottomNavigationBar
  late AnimationController _animationController; // Controller cho animation

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
    // Khởi tạo AnimationController và ScaleAnimation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Hủy AnimationController khi không cần thiết
    super.dispose();
  }

  Future<void> _loadData() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final recurringTransactionProvider = Provider.of<RecurringTransactionProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    await Future.wait([
      transactionProvider.fetchTransactions(),
      recurringTransactionProvider.fetchRecurringTransactions(),
      categoryProvider.fetchCategories(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ số item được chọn
      _animationController.forward().then((_) {
        _animationController.reverse(); // Chạy animation phóng to/nhỏ
      });
    });

    // Xử lý điều hướng
    if (index == 1) {
      _showAddOptions(context);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Expense Manager', style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        )),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load data. Please try again.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            );
          } else {
            return _buildContent(context, authProvider);
          }
        },
      ),
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(icon: Icons.dashboard, title: 'Dashboard'),
          TabItem(icon: Icons.add_circle, title: 'Add'),
          TabItem(icon: Icons.notifications, title: 'Notifications'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
        style: TabStyle.fixedCircle, // Hiệu ứng lồi lõm
        backgroundColor: Theme.of(context).colorScheme.primary,
        activeColor: Colors.white,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final recurringTransactionProvider = Provider.of<RecurringTransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, size: 40, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text(
                'Hello, ${authProvider.name.isNotEmpty ? authProvider.name : "Guest"}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPieChartRow(
            context,
            transactionProvider,
            categoryProvider,
            'Monthly Transactions',
            true,
          ),
          SizedBox(height: 16),
          _buildPieChartRow(
            context,
            recurringTransactionProvider,
            categoryProvider,
            'Recurring Transactions',
            false,
          ),
          SizedBox(height: 16),
          _buildCategorySection(
              context, categoryProvider, 'income', 'Income Categories'),
          SizedBox(height: 16),
          _buildCategorySection(
              context, categoryProvider, 'expense', 'Expense Categories'),
        ],
      ),
    );
  }

  // Hàm tạo màu ngẫu nhiên với độ tương phản cao
  Color _generateRandomColor(int seed) {
    final random = Random(seed);
    // Tạo màu với độ sáng và độ bão hòa cao để đảm bảo tương phản
    return HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360, // Hue (0-360)
      0.8, // Saturation (0.8 để màu sắc rực rỡ)
      0.6, // Lightness (0.6 để màu không quá tối hoặc quá sáng)
    ).toColor();
  }

  Widget _buildPieChartRow(
      BuildContext context,
      dynamic provider,
      CategoryProvider categoryProvider,
      String title,
      bool isTransaction,
      ) {
    final transactions = isTransaction
        ? provider.transactions
        : provider.recurringTransactions;

    final totalAmount = transactions.fold(
      0.0,
          (sum, transaction) => sum + transaction.amount,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Biểu đồ bên trái
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final now = DateTime.now();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticScreen(
                          currentMonth: now.month,
                          currentYear: now.year,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sections: transactions.map<PieChartSectionData>((transaction) {
                          final category = categoryProvider.categories.firstWhere(
                                (cat) => cat.id == transaction.categoryId,
                            orElse: () => Category(id: 0, name: 'Unknown', type: 'Other', userId: 0),
                          );
                          return PieChartSectionData(
                            value: transaction.amount,
                            color: _generateRandomColor(transaction.categoryId), // Sử dụng màu ngẫu nhiên tương phản cao
                            radius: 30,
                            title: '',
                          );
                        }).toList(),
                        centerSpaceRadius: 20,
                        sectionsSpace: 2,
                      ),
                      swapAnimationDuration: Duration(milliseconds: 400),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            SizedBox(width: 16),
            // Thông tin category bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 8),
                  ...transactions.map((transaction) {
                    final category = categoryProvider.categories.firstWhere(
                          (cat) => cat.id == transaction.categoryId,
                      orElse: () => Category(id: 0, name: 'Unknown', type: 'Other', userId: 0),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _generateRandomColor(transaction.categoryId), // Sử dụng màu ngẫu nhiên tương phản cao
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(category.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context,
      CategoryProvider categoryProvider,
      String type,
      String title,
      ) {
    final categories = categoryProvider.categories
        .where((category) => category.type == type)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                _showAddCategoryDialog(context, type);
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        categories.isEmpty
            ? Center(
          child: Text(
            'No categories available',
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        )
            : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Hiển thị tối đa 4 items trên một dòng
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 1, // Đảm bảo các item có tỷ lệ vuông
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, String type) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add Category',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Chiều cao tự động co lại theo nội dung
            children: [
              // TextField để nhập tên category
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20),

              // Nút để chọn loại category (Income/Expense)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryTypeButton(
                    context,
                    label: 'Income',
                    isSelected: type == 'income',
                    onTap: () {
                      setState(() {
                        type = 'income';
                      });
                    },
                  ),
                  _buildCategoryTypeButton(
                    context,
                    label: 'Expense',
                    isSelected: type == 'expense',
                    onTap: () {
                      setState(() {
                        type = 'expense';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Nút hủy
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
            ),

            // Nút thêm
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await Provider.of<CategoryProvider>(context, listen: false)
                      .addCategory(nameController.text.trim(), type);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Widget để xây dựng nút chọn loại category
  Widget _buildCategoryTypeButton(BuildContext context,
      {required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép cuộn nếu nội dung dài
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Chiều cao tự động co lại theo nội dung
            children: [
              // Tiêu đề
              Text(
                'Add Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16),

              // Nút thêm giao dịch
              _buildAddOptionItem(
                context,
                icon: Icons.add,
                label: 'Add Transaction',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/transactions');
                },
              ),

              // Nút thêm giao dịch định kỳ
              _buildAddOptionItem(
                context,
                icon: Icons.repeat,
                label: 'Add Recurring Transaction',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/recurring-transactions');
                },
              ),

              // Nút đóng
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget để xây dựng các tùy chọn thêm
  Widget _buildAddOptionItem(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}