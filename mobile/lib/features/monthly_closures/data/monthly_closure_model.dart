class MonthlyClosureModel {
  final int id;
  final int year;
  final int month;
  final double income;
  final double expense;
  final double investment;
  final double balance;
  final int transactionsCount;
  final String closedAt;
  final int userId;

  MonthlyClosureModel({
    required this.id,
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
    required this.transactionsCount,
    required this.closedAt,
    required this.userId,
  });

  factory MonthlyClosureModel.fromJson(Map<String, dynamic> json) {
    return MonthlyClosureModel(
      id: json['id'],
      year: json['year'],
      month: json['month'],
      income: double.parse(json['income'].toString()),
      expense: double.parse(json['expense'].toString()),
      investment: double.parse(json['investment'].toString()),
      balance: double.parse(json['balance'].toString()),
      transactionsCount: json['transactions_count'],
      closedAt: json['closed_at'],
      userId: json['user_id'],
    );
  }
}