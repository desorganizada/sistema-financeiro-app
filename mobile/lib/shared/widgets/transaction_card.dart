import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String description;
  final String type;
  final String date;
  final String amount;
  final String currency;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.description,
    required this.type,
    required this.date,
    required this.amount,
    required this.currency,
    this.onTap,
  });

  Color _typeColor() {
    switch (type) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'investment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _typeLabel() {
    switch (type) {
      case 'income':
        return 'Receita';
      case 'expense':
        return 'Despesa';
      case 'investment':
        return 'Investimento';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$date • ${_typeLabel()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '$amount $currency',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _typeColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}