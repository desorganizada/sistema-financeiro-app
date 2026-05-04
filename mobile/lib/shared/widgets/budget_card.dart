import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final int year;
  final int month;
  final int categoryId;
  final String plannedAmount;
  final VoidCallback? onTap;

  const BudgetCard({
    super.key,
    required this.year,
    required this.month,
    required this.categoryId,
    required this.plannedAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          title: Text('Categoria ID: $categoryId'),
          subtitle: Text('Período: $month/$year'),
          trailing: Text(
            plannedAmount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}