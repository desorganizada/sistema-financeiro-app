import 'package:flutter/material.dart';

class ExchangeRateCard extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final String rate;
  final String rateDate;

  const ExchangeRateCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$fromCurrency → $toCurrency'),
        subtitle: Text('Data: $rateDate'),
        trailing: Text(
          rate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}