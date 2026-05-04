class MonthlyEvolutionModel {
  final int month;
  final double income;
  final double expense;
  final double investment;
  final double balance;

  MonthlyEvolutionModel({
    required this.month,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
  });

  factory MonthlyEvolutionModel.fromJson(Map<String, dynamic> json) {
    return MonthlyEvolutionModel(
      month: json['month'],
      income: double.parse(json['income'].toString()),
      expense: double.parse(json['expense'].toString()),
      investment: double.parse(json['investment'].toString()),
      balance: double.parse(json['balance'].toString()),
    );
  }
}