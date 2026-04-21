class AccountModel {
  final int id;
  final String name;
  final String type;
  final String currency;
  final double initialBalance;
  final String? initialBalanceDate;
  final int userId;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
    required this.initialBalanceDate,
    required this.userId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      initialBalance: json['initial_balance'] != null
          ? double.tryParse(json['initial_balance'].toString()) ?? 0.0
          : 0.0,
      initialBalanceDate: json['initial_balance_date']?.toString(),
      userId: json['user_id'] ?? 0,
    );
  }
}