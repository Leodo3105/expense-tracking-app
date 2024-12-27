// main.dart
import 'package:flutter/material.dart';
import 'screens/loginScreen.dart';
import 'screens/dashboardScreen.dart';
import 'screens/categoryScreen.dart';
import 'screens/transactionScreen.dart';
import 'screens/historyScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData.dark(),
      home:  TransactionHistoryScreen(),
    );
  }
}
