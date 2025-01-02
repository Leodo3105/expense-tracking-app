import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserScreen extends StatelessWidget {
  final TextEditingController spendingLimitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user?.name ?? ''}'),
            Text('Email: ${user?.email ?? ''}'),
            SizedBox(height: 16),
            TextField(
              controller: spendingLimitController,
              decoration: InputDecoration(
                labelText: 'Set Spending Limit',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final limit = double.tryParse(spendingLimitController.text);
                if (limit != null) {
                  userProvider.setSpendingLimit(limit);
                }
              },
              child: Text('Update Limit'),
            ),
          ],
        ),
      ),
    );
  }
}
