import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../data/dashboard_category_model.dart';
import '../data/dashboard_service.dart';
import '../data/monthly_evolution_model.dart';

class DashboardAnalyticsPage extends StatefulWidget {
  const DashboardAnalyticsPage({super.key});

  @override
  State<DashboardAnalyticsPage> createState() => _DashboardAnalyticsPageState();
}

class _DashboardAnalyticsPageState extends State<DashboardAnalyticsPage> {
  final DashboardService _dashboardService = DashboardService();

  late Future<_DashboardAnalyticsData> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();

    _future = _fetchData(
      year: now.year,
      month: now.month,
    );
  }

  Future<_DashboardAnalyticsData> _fetchData({
    required int year,
    required int month,
  }) async {
    final categories = await _dashboardService.getByCategory(
      year: year,
      month: month,
    );

    final evolution = await _dashboardService.getMonthlyEvolution(
      year: year,
    );

    return _DashboardAnalyticsData(
      categories: categories,
      evolution: evolution,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    await _future;
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  List<_CategoryExpenseItem> _buildTopExpenseItems(
    List<DashboardCategoryModel> categories,
  ) {
    final filtered = categories
        .where((item) => item.type.toLowerCase() == 'expense')
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return filtered.take(5).map((item) {
      return _CategoryExpenseItem(
        label: item.categoryName,
        value: item.total,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Dashboard Analítico'),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<_DashboardAnalyticsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'Carregando gráficos...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final categoryItems = _buildTopExpenseItems(data.categories);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gastos por categoria - Top Despesas
                  _StyledCard(
                    child: _TopExpenseChart(
                      items: categoryItems,
                      formatCurrency: _formatCurrency,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Saldo ao longo do ano - Gráfico de área
                  _StyledCard(
                    child: _BalanceAreaChart(
                      evolution: data.evolution,
                      formatCurrency: _formatCurrency,
                      getMonthName: _getMonthName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Despesas ao longo do ano - Gráfico de barras
                  _StyledCard(
                    child: _ExpenseBarChart(
                      evolution: data.evolution,
                      formatCurrency: _formatCurrency,
                      getMonthName: _getMonthName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Comparativo Receitas vs Despesas
                  _StyledCard(
                    child: _IncomeExpenseComparison(
                      evolution: data.evolution,
                      formatCurrency: _formatCurrency,
                      getMonthName: _getMonthName,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardAnalyticsData {
  final List<DashboardCategoryModel> categories;
  final List<MonthlyEvolutionModel> evolution;

  _DashboardAnalyticsData({
    required this.categories,
    required this.evolution,
  });
}

class _CategoryExpenseItem {
  final String label;
  final double value;

  _CategoryExpenseItem({
    required this.label,
    required this.value,
  });
}

class _StyledCard extends StatelessWidget {
  final Widget child;

  const _StyledCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Gráfico de Top Despesas (Barras horizontais)
class _TopExpenseChart extends StatelessWidget {
  final List<_CategoryExpenseItem> items;
  final String Function(double) formatCurrency;

  const _TopExpenseChart({
    required this.items,
    required this.formatCurrency,
  });

  String _shorten(String value) {
    if (value.length <= 20) return value;
    return '${value.substring(0, 20)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textMedium),
              const SizedBox(height: 12),
              Text(
                'Nenhuma despesa encontrada',
                style: TextStyle(color: AppColors.textMedium, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryTerracota,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Top Despesas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Principais gastos do mês atual',
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final progress = maxValue == 0 ? 0.0 : item.value / maxValue;
          final color = _getBarColor(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        _shorten(item.label),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: AppColors.borderSand,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Text(
                        formatCurrency(item.value),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getBarColor(int index) {
    const colors = [
      AppColors.primaryTerracota,
      AppColors.lightTerracota,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }
}

// Gráfico de Área - Saldo ao longo do ano
class _BalanceAreaChart extends StatelessWidget {
  final List<MonthlyEvolutionModel> evolution;
  final String Function(double) formatCurrency;
  final String Function(int) getMonthName;

  const _BalanceAreaChart({
    required this.evolution,
    required this.formatCurrency,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < evolution.length; i++) {
      spots.add(FlSpot(i.toDouble(), evolution[i].balance));
    }

    final maxBalance = evolution.map((e) => e.balance).reduce((a, b) => a > b ? a : b);
    final minBalance = evolution.map((e) => e.balance).reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryTerracota,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Evolução do Saldo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Acompanhe a evolução do saldo mês a mês',
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxBalance - minBalance) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderSand,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < evolution.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            getMonthName(index + 1),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatCurrency(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMedium,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borderSand, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.success.withOpacity(0.2),
                  ),
                ),
              ],
              minY: minBalance < 0 ? minBalance - (minBalance.abs() * 0.1) : 0,
              maxY: maxBalance + (maxBalance * 0.1),
            ),
          ),
        ),
      ],
    );
  }
}

// Gráfico de Barras - Despesas ao longo do ano
class _ExpenseBarChart extends StatelessWidget {
  final List<MonthlyEvolutionModel> evolution;
  final String Function(double) formatCurrency;
  final String Function(int) getMonthName;

  const _ExpenseBarChart({
    required this.evolution,
    required this.formatCurrency,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final maxExpense = evolution.map((e) => e.expense).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Despesas Mensais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Veja o comportamento das despesas ao longo do ano',
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxExpense + (maxExpense * 0.1),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderSand,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < evolution.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            getMonthName(index + 1),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatCurrency(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMedium,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borderSand, width: 1),
              ),
              barGroups: List.generate(evolution.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: evolution[index].expense,
                      color: AppColors.error,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// Comparativo Receitas vs Despesas
class _IncomeExpenseComparison extends StatelessWidget {
  final List<MonthlyEvolutionModel> evolution;
  final String Function(double) formatCurrency;
  final String Function(int) getMonthName;

  const _IncomeExpenseComparison({
    required this.evolution,
    required this.formatCurrency,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryTerracota,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Receitas vs Despesas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Comparativo mensal de entradas e saídas',
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderSand,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < evolution.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            getMonthName(index + 1),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatCurrency(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMedium,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borderSand, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(evolution.length, (index) => FlSpot(index.toDouble(), evolution[index].income)),
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: List.generate(evolution.length, (index) => FlSpot(index.toDouble(), evolution[index].expense)),
                  isCurved: true,
                  color: AppColors.error,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppColors.success, label: 'Receitas'),
            const SizedBox(width: 24),
            _LegendItem(color: AppColors.error, label: 'Despesas'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }
}