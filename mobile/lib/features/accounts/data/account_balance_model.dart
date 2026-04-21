class AccountBalanceModel {
  final int accountId;
  final String accountName;
  final String currency;
  final double income;
  final double expense;
  final double investment;
  final double balance;

  AccountBalanceModel({
    required this.accountId,
    required this.accountName,
    required this.currency,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory AccountBalanceModel.fromJson(Map<String, dynamic> json) {
    return AccountBalanceModel(
      accountId: (json['account_id'] as num?)?.toInt() ??
          int.tryParse(json['account_id']?.toString() ?? '0') ??
          0,
      accountName: json['account_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      income: _toDouble(json['income']),
      expense: _toDouble(json['expense']),
      investment: _toDouble(json['investment']),
      balance: _toDouble(json['balance']),
    );
  }
}