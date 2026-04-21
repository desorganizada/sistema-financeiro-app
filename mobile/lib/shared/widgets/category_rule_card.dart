import 'package:flutter/material.dart';

class CategoryRuleCard extends StatelessWidget {
  final String keyword;
  final int priority;
  final int categoryId;

  const CategoryRuleCard({
    super.key,
    required this.keyword,
    required this.priority,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(keyword),
        subtitle: Text('Prioridade: $priority'),
        trailing: Text(
          'Categoria $categoryId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}