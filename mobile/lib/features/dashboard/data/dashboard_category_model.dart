class DashboardCategoryModel {
  final int categoryId;
  final String categoryName;
  final String type;
  final double total;

  DashboardCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.total,
  });

  factory DashboardCategoryModel.fromJson(Map<String, dynamic> json) {
    return DashboardCategoryModel(
      categoryId: int.parse(json['category_id'].toString()),
      categoryName: json['category_name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      total: double.parse(json['total'].toString()), // 🔥 AQUI É A CORREÇÃO
    );
  }
}