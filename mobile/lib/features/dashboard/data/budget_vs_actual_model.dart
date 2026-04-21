class BudgetVsActualModel {
  final int categoryId;
  final String categoryName;
  final double planned;
  final double actual;
  final double difference;

  BudgetVsActualModel({
    required this.categoryId,
    required this.categoryName,
    required this.planned,
    required this.actual,
    required this.difference,
  });

  factory BudgetVsActualModel.fromJson(Map<String, dynamic> json) {
    return BudgetVsActualModel(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      planned: double.parse(json['planned'].toString()),
      actual: double.parse(json['actual'].toString()),
      difference: double.parse(json['difference'].toString()),
    );
  }
}