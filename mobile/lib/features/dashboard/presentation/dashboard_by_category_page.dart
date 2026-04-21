import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/dashboard_category_model.dart';
import '../data/dashboard_service.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

class DashboardByCategoryPage extends StatefulWidget {
  const DashboardByCategoryPage({super.key});

  @override
  State<DashboardByCategoryPage> createState() =>
      _DashboardByCategoryPageState();
}

class _DashboardByCategoryPageState extends State<DashboardByCategoryPage> {
  final DashboardService _dashboardService = DashboardService();

  late Future<List<DashboardCategoryModel>> _categoriesFuture;

  int touchedIndex = -1;

  final List<Color> _chartColors = const [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final now = DateTime.now();
    _categoriesFuture = _dashboardService.getByCategory(
      year: now.year,
      month: now.month,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      touchedIndex = -1;
      _loadCategories();
    });

    await _categoriesFuture;
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double _getTotal(List<DashboardCategoryModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  Color _getColor(int index) {
    return _chartColors[index % _chartColors.length];
  }

  List<DashboardCategoryModel> _normalizeItems(
    List<DashboardCategoryModel> items,
  ) {
    final sorted = [...items]..sort((a, b) => b.total.compareTo(a.total));

    if (sorted.length <= 5) {
      return sorted;
    }

    final topItems = sorted.take(4).toList();
    final otherItems = sorted.skip(4).toList();

    final othersTotal = otherItems.fold<double>(
      0.0,
      (sum, item) => sum + item.total,
    );

    topItems.add(
      DashboardCategoryModel(
        categoryId: -1,
        categoryName: 'Outros',
        total: othersTotal,
        type: 'expense',
      ),
    );

    return topItems;
  }

  List<PieChartSectionData> _buildSections(
    List<DashboardCategoryModel> items,
  ) {
    final total = _getTotal(items);

    return List.generate(items.length, (index) {
      final item = items[index];
      final isTouched = index == touchedIndex;
      final percentage = total == 0 ? 0.0 : (item.total / total) * 100;

      return PieChartSectionData(
        color: _getColor(index),
        value: item.total,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 72 : 62,
        titleStyle: TextStyle(
          fontSize: isTouched ? 15 : 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(List<DashboardCategoryModel> items) {
    final total = _getTotal(items);

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percent = total == 0 ? 0.0 : (item.total / total) * 100;
        final isActive = touchedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFEAF3EA)
                : const Color(0xFFF8FAF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? _getColor(index).withOpacity(0.45)
                  : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getColor(index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.categoryName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatCurrency(item.total),
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard(List<DashboardCategoryModel> items) {
    final normalizedItems = _normalizeItems(items);
    final total = _getTotal(normalizedItems);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Despesas por categoria',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 900;

              if (isSmall) {
                return Column(
                  children: [
                    SizedBox(
                      height: 290,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 80,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }

                                    touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sections: _buildSections(normalizedItems),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatCurrency(total),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLegend(normalizedItems),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 80,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }

                                    touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sections: _buildSections(normalizedItems),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatCurrency(total),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildLegend(normalizedItems),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3E8DD),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: const Text('Despesas por categoria'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<DashboardCategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando resumo por categoria...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(
                    title: 'Nenhum dado encontrado',
                    subtitle: 'Não há categorias com movimentação no período.',
                    icon: Icons.pie_chart_outline,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChartCard(items),
              ],
            ),
          );
        },
      ),
    );
  }
}