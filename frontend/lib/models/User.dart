class User {
  final int id;
  final String name;
  final String email;
  final double? spendingLimit;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.spendingLimit,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      spendingLimit: json['spendingLimit'] != null ? double.parse(json['spendingLimit'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'spendingLimit': spendingLimit,
    };
  }
}
