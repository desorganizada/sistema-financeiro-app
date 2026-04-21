import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String type;
  final String? groupName;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.type,
    required this.groupName,
    this.onTap,
  });

  // 🔥 Tradução do tipo
  String _translateType(String value) {
    switch (value.toLowerCase().trim()) {
      case 'income':
        return 'receita';
      case 'expense':
        return 'despesa';
      case 'investment':
        return 'investimento';  
      default:
        return value;
    }
  }

  // 🔥 Tradução do grupo
  String _translateGroup(String? value) {
    if (value == null || value.trim().isEmpty) return '';

    switch (value.toLowerCase().trim()) {
      case 'fixed':
        return 'fixa';
      case 'variable':
        return 'variável';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translatedType = _translateType(type);
    final translatedGroup = _translateGroup(groupName);

    final subtitleText = translatedGroup.isEmpty
        ? translatedType
        : '$translatedType • $translatedGroup';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          title: Text(name),
          subtitle: Text(subtitleText),
        ),
      ),
    );
  }
}