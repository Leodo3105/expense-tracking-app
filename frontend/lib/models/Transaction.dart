class Transaction {
  final int id;
  final int userId;
  final double amount;
  final DateTime date;
  final int categoryId;
  final String? note;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0, // Chuyển đổi thành double
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
    };
  }
}
