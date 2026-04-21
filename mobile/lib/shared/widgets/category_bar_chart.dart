import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryBarChartItem {
  final String label;
  final double value;

  CategoryBarChartItem({
    required this.label,
    required this.value,
  });
}

class CategoryBarChart extends StatelessWidget {
  final List<CategoryBarChartItem> items;

  const CategoryBarChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = items
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          maxY: maxValue == 0 ? 10 : maxValue * 1.2,
          alignment: BarChartAlignment.spaceAround,
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
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }

                  final label = items[index].label;
                  final shortLabel =
                      label.length > 8 ? '${label.substring(0, 8)}…' : label;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        shortLabel,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            items.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: items[index].value,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}