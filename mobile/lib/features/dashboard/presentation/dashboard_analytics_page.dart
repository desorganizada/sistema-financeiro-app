import 'package:flutter/material.dart';

import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/monthly_line_chart.dart';
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

  final List<Color> _barColors = const [
    Color(0xFFF4B400),
    Color(0xFF5B8DEF),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
  ];

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
      backgroundColor: const Color(0xFFF6F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3E8DD),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: const Text('Dashboard analítico'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardAnalyticsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando gráficos...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final categoryItems = _buildTopExpenseItems(data.categories);

          final balanceItems = data.evolution
              .map(
                (item) => MonthlyLineChartItem(
                  month: item.month,
                  value: item.balance,
                ),
              )
              .toList();

          final expenseItems = data.evolution
              .map(
                (item) => MonthlyLineChartItem(
                  month: item.month,
                  value: item.expense,
                ),
              )
              .toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader(
                  title: 'Gastos por categoria',
                  subtitle: 'Top despesas do mês atual',
                ),
                const SizedBox(height: 12),
                _StyledCard(
                  child: _TopExpenseBarCard(
                    items: categoryItems,
                    colors: _barColors,
                    formatCurrency: _formatCurrency,
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Saldo ao longo do ano',
                  subtitle: 'Acompanhe a evolução do saldo mês a mês',
                ),
                const SizedBox(height: 12),
                _StyledCard(
                  child: MonthlyLineChart(
                    title: 'Saldo ao longo do ano',
                    items: balanceItems,
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Despesas ao longo do ano',
                  subtitle: 'Veja o comportamento das despesas no ano',
                ),
                const SizedBox(height: 12),
                _StyledCard(
                  child: MonthlyLineChart(
                    title: 'Despesas ao longo do ano',
                    items: expenseItems,
                  ),
                ),
              ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _StyledCard extends StatelessWidget {
  final Widget child;

  const _StyledCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TopExpenseBarCard extends StatelessWidget {
  final List<_CategoryExpenseItem> items;
  final List<Color> colors;
  final String Function(double value) formatCurrency;

  const _TopExpenseBarCard({
    required this.items,
    required this.colors,
    required this.formatCurrency,
  });

  String _shorten(String value) {
    if (value.length <= 22) return value;
    return '${value.substring(0, 22)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Nenhuma despesa encontrada no período.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    final maxValue = items
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 5 despesas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 20),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final progress = maxValue == 0 ? 0.0 : item.value / maxValue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    _shorten(item.label),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors[index % colors.length],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: Text(
                    formatCurrency(item.value),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B6F97),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}