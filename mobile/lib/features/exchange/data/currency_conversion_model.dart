class CurrencyConversionModel {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final double convertedAmount;
  final String rateDateUsed;
  final bool autoSynced;

  CurrencyConversionModel({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.convertedAmount,
    required this.rateDateUsed,
    required this.autoSynced,
  });

  factory CurrencyConversionModel.fromJson(Map<String, dynamic> json) {
    return CurrencyConversionModel(
      amount: double.parse(json['amount'].toString()),
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      exchangeRate: double.parse(json['exchange_rate'].toString()),
      convertedAmount: double.parse(json['converted_amount'].toString()),
      rateDateUsed: json['rate_date_used'],
      autoSynced: json['auto_synced'] ?? false,
    );
  }
}