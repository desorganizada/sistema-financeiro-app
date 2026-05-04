import 'package:flutter/material.dart';

import '../../../shared/widgets/budget_vs_actual_card.dart';
import '../data/budget_vs_actual_model.dart';
import '../data/dashboard_service.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

class BudgetVsActualPage extends StatefulWidget {
  const BudgetVsActualPage({super.key});

  @override
  State<BudgetVsActualPage> createState() => _BudgetVsActualPageState();
}

class _BudgetVsActualPageState extends State<BudgetVsActualPage> {
  final DashboardService _dashboardService = DashboardService();

  late Future<List<BudgetVsActualModel>> _itemsFuture;

  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadData();
  }

  void _loadData() {
    _itemsFuture = _dashboardService.getBudgetVsActual(
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    await _itemsFuture;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  Future<void> _pickMonthYear() async {
    final now = DateTime.now();

    final year = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Selecione o ano'),
          children: List.generate(
            6,
            (index) {
              final y = now.year - 2 + index;
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(context, y),
                child: Text(y.toString()),
              );
            },
          ),
        );
      },
    );

    if (year == null || !mounted) return;

    final month = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Selecione o mês'),
          children: List.generate(
            12,
            (index) {
              final m = index + 1;
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(context, m),
                child: Text(m.toString()),
              );
            },
          ),
        );
      },
    );

    if (month == null) return;

    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planejado vs Realizado $_selectedMonth/$_selectedYear'),
        actions: [
          IconButton(
            onPressed: _pickMonthYear,
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<BudgetVsActualModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando planejado vs realizado...',
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
                    subtitle: 'Não há dados de orçamento para este período.',
                    icon: Icons.bar_chart_outlined,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return BudgetVsActualCard(
                  categoryName: item.categoryName,
                  planned: _formatAmount(item.planned),
                  actual: _formatAmount(item.actual),
                  difference: _formatAmount(item.difference),
                );
              },
            ),
          );
        },
      ),
    );
  }
}