// lib/features/accounts/data/account_model.dart

class AccountModel {
  final int id;
  final String name;
  final String type;
  final String currency;
  final int userId;
  final double? balance;
  final double? income;
  final double? expense;
  final double? investment;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.userId,
    this.balance,
    this.income,
    this.expense,
    this.investment,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      currency: json['currency'],
      userId: json['user_id'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      investment: (json['investment'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currency': currency,
      'user_id': userId,
      'balance': balance,
      'income': income,
      'expense': expense,
      'investment': investment,
    };
  }
}