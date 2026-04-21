class UserModel {
  final int id;
  final String email;
  final String name;
  final String baseCurrency;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.baseCurrency,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      baseCurrency: json['base_currency'] ?? 'BRL',
      isAdmin: json['is_admin'] ?? false,
    );
  }
}