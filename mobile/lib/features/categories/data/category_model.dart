class CategoryModel {
  final int id;
  final String name;
  final String type;
  final String? groupName;
  final int userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.groupName,
    required this.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: (json['type'] ?? '').toString(),
      groupName: json['group_name']?.toString(),
      userId: json['user_id'] as int,
    );
  }
}