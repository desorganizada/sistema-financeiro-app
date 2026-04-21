class TransactionModel {
  final int id;
  final String description;
  final String type;
  final double amountOriginal;
  final String originalCurrency;
  final double exchangeRate;
  final double amountConverted;
  final String date;
  final int userId;
  final int accountId;
  final int categoryId;

  TransactionModel({
    required this.id,
    required this.description,
    required this.type,
    required this.amountOriginal,
    required this.originalCurrency,
    required this.exchangeRate,
    required this.amountConverted,
    required this.date,
    required this.userId,
    required this.accountId,
    required this.categoryId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amountOriginal: json['amount_original'] != null
          ? double.tryParse(json['amount_original'].toString()) ?? 0.0
          : 0.0,
      originalCurrency: json['original_currency']?.toString() ?? '',
      exchangeRate: json['exchange_rate'] != null
          ? double.tryParse(json['exchange_rate'].toString()) ?? 1.0
          : 1.0,
      amountConverted: json['amount_converted'] != null
          ? double.tryParse(json['amount_converted'].toString()) ?? 0.0
          : 0.0,
      date: json['date']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
    );
  }
}