class CategoryRuleModel {
  final int id;
  final String keyword;
  final int priority;
  final int userId;
  final int categoryId;

  CategoryRuleModel({
    required this.id,
    required this.keyword,
    required this.priority,
    required this.userId,
    required this.categoryId,
  });

  factory CategoryRuleModel.fromJson(Map<String, dynamic> json) {
    return CategoryRuleModel(
      id: json['id'],
      keyword: json['keyword'],
      priority: json['priority'],
      userId: json['user_id'],
      categoryId: json['category_id'],
    );
  }
}