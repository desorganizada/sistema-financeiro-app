class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final String baseCurrency;
  final bool isAdmin;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.baseCurrency,
    required this.isAdmin,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      baseCurrency: json['base_currency'] ?? 'BRL',
      isAdmin: json['is_admin'] ?? false,
    );
  }
}