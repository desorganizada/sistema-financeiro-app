import 'package:flutter/material.dart';

class MonthlyEvolutionTile extends StatelessWidget {
  final String monthLabel;
  final String income;
  final String expense;
  final String investment;
  final String balance;

  const MonthlyEvolutionTile({
    super.key,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Receitas: $income'),
            Text('Despesas: $expense'),
            Text('Investimentos: $investment'),
            Text(
              'Saldo: $balance',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}