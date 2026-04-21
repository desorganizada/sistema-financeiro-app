import 'package:flutter/material.dart';

class BudgetVsActualCard extends StatelessWidget {
  final String categoryName;
  final String planned;
  final String actual;
  final String difference;

  const BudgetVsActualCard({
    super.key,
    required this.categoryName,
    required this.planned,
    required this.actual,
    required this.difference,
  });

  Color _differenceColor() {
    final value = double.tryParse(difference) ?? 0;

    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Planejado: $planned'),
            Text('Realizado: $actual'),
            Text(
              'Diferença: $difference',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _differenceColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}