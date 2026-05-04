import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyLineChartItem {
  final int month;
  final double value;

  MonthlyLineChartItem({
    required this.month,
    required this.value,
  });
}

class MonthlyLineChart extends StatelessWidget {
  final List<MonthlyLineChartItem> items;
  final String title;

  const MonthlyLineChart({
    super.key,
    required this.items,
    required this.title,
  });

  String _monthLabel(int month) {
    const labels = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    if (month < 1 || month > 12) return '';
    return labels[month];
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxY = items
        .map((e) => e.value)
        .fold<double>(0, (prev, element) => element > prev ? element : prev);

    if (maxY == 0) {
      maxY = 10;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY * 1.2,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final month = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _monthLabel(month),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: items
                      .map((e) => FlSpot(e.month.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}