class DashboardSummaryModel {
  final int year;
  final int month;
  final double income;
  final double expense;
  final double investment;
  final double balance;
  final int transactionsCount;

  DashboardSummaryModel({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
    required this.transactionsCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      year: json['year'],
      month: json['month'],
      income: double.parse(json['income'].toString()),
      expense: double.parse(json['expense'].toString()),
      investment: double.parse(json['investment'].toString()),
      balance: double.parse(json['balance'].toString()),
      transactionsCount: json['transactions_count'],
    );
  }
}