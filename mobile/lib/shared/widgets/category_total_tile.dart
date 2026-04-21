import 'package:flutter/material.dart';

class CategoryTotalTile extends StatelessWidget {
  final String categoryName;
  final String type;
  final String total;

  const CategoryTotalTile({
    super.key,
    required this.categoryName,
    required this.type,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(categoryName),
        subtitle: Text(type),
        trailing: Text(
          total,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}