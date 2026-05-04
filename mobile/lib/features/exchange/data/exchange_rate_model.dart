class ExchangeRateModel {
  final int id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final String rateDate;
  final int userId;

  ExchangeRateModel({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateDate,
    required this.userId,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      id: json['id'],
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      rate: double.parse(json['rate'].toString()),
      rateDate: json['rate_date'],
      userId: json['user_id'],
    );
  }
}