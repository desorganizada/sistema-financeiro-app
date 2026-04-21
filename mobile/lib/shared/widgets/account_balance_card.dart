import 'package:flutter/material.dart';

class AccountBalanceCard extends StatelessWidget {
  final String name;
  final String currency;
  final String initialBalance;
  final String income;
  final String expense;
  final String investment;
  final String balance;
  final VoidCallback? onTap;

  const AccountBalanceCard({
    super.key,
    required this.name,
    required this.currency,
    required this.initialBalance,
    required this.income,
    required this.expense,
    required this.investment,
    required this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Moeda: $currency'),
              const SizedBox(height: 12),
              Text('Saldo inicial: $initialBalance'),
              Text('Receitas: $income'),
              Text('Despesas: $expense'),
              Text('Investimentos: $investment'),
              const SizedBox(height: 8),
              Text(
                'Saldo atual: $balance',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}