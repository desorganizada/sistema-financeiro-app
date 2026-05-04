// lib/features/transactions/data/transaction_model.dart

class TransactionModel {
  final int id;
  final String description;
  final String type;
  final double amountOriginal;
  final String originalCurrency;
  final double? exchangeRate;
  final double? amountConverted;
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
    this.exchangeRate,
    this.amountConverted,
    required this.date,
    required this.userId,
    required this.accountId,
    required this.categoryId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // 🔧 CORREÇÃO: O valor já vem como número do backend
    // Não precisa de toDouble() se já for double
    double getAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return TransactionModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      type: json['type'] ?? 'expense',
      amountOriginal: getAmount(json['amount_original']),
      originalCurrency: json['original_currency'] ?? 'BRL',
      exchangeRate: json['exchange_rate'] != null 
          ? getAmount(json['exchange_rate']) 
          : null,
      amountConverted: json['amount_converted'] != null 
          ? getAmount(json['amount_converted']) 
          : null,
      date: json['date'] ?? '',
      userId: json['user_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type,
      'amount_original': amountOriginal,
      'original_currency': originalCurrency,
      'exchange_rate': exchangeRate,
      'amount_converted': amountConverted,
      'date': date,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
    };
  }
}