class BudgetModel {
  final int id;
  final int year;
  final int month;
  final double plannedAmount;
  final int userId;
  final int categoryId;

  BudgetModel({
    required this.id,
    required this.year,
    required this.month,
    required this.plannedAmount,
    required this.userId,
    required this.categoryId,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      year: json['year'],
      month: json['month'],
      plannedAmount: double.parse(json['planned_amount'].toString()),
      userId: json['user_id'],
      categoryId: json['category_id'],
    );
  }
}