import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${transaction.amount}'),
      subtitle: Text(transaction.note ?? 'No note'),
      trailing: Text(transaction.date.toLocal().toString().split(' ')[0]),
    );
  }
}
