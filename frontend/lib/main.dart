import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import './providers/category_provider.dart';
import './providers/notification_provider.dart';
import './providers/recurring_transaction_provider.dart';
import './providers/statistic_provider.dart';
import './providers/transaction_provider.dart';
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/category_screen.dart';
import './screens/notification_screen.dart';
import './screens/recurring_transaction_screen.dart';
import './screens/statistic_screen.dart';
import './screens/transaction_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (ctx, authProvider, categoryProvider) {
            categoryProvider ??= CategoryProvider();
            categoryProvider.token = authProvider.token;
            return categoryProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (ctx, authProvider, transactionProvider) {
            transactionProvider ??= TransactionProvider();
            transactionProvider.token = authProvider.token;
            return transactionProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecurringTransactionProvider>(
          create: (_) => RecurringTransactionProvider(),
          update: (ctx, authProvider, recurringTransactionProvider) {
            recurringTransactionProvider ??= RecurringTransactionProvider();
            recurringTransactionProvider.token = authProvider.token;
            return recurringTransactionProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (ctx, authProvider, notificationProvider) {
            notificationProvider ??= NotificationProvider();
            notificationProvider.token = authProvider.token;
            return notificationProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, StatisticProvider>(
          create: (_) => StatisticProvider(),
          update: (ctx, authProvider, statisticProvider) {
            statisticProvider ??= StatisticProvider();
            statisticProvider.token = authProvider.token;
            return statisticProvider;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Manager',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: authProvider.isAuthenticated ? '/' : '/login',
          routes: {
            '/': (context) => HomeScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/categories': (context) => CategoryScreen(),
            '/notifications': (context) => NotificationScreen(),
            '/recurring-transactions': (context) => RecurringTransactionScreen(),
            '/statistics': (context) {
              final now = DateTime.now();
              return StatisticScreen(
                currentMonth: now.month,
                currentYear: now.year,
              );
            },
            '/transactions': (context) => TransactionScreen(),
          },
        );
      },
    );
  }
}
