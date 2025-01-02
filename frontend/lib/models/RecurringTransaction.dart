class RecurringTransaction {
  final int id;
  final int userId;
  final int categoryId;
  final double amount;
  final String frequency;
  final DateTime nextDate;
  final String? note;

  RecurringTransaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    this.note,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0, // Chuyển đổi thành double
      frequency: json['frequency'],
      nextDate: DateTime.parse(json['nextDate']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'frequency': frequency,
      'nextDate': nextDate.toIso8601String(),
      'note': note,
    };
  }
}
