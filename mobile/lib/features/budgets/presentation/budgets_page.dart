import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/budget_card.dart';
import '../data/budget_model.dart';
import '../data/budget_service.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final BudgetService _budgetService = BudgetService();

  late Future<List<BudgetModel>> _budgetsFuture;

  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgetsFuture = _budgetService.getBudgets(
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadBudgets();
    });

    await _budgetsFuture;
  }

  Future<void> _goToCreateBudget() async {
    await context.push(
      '/budgets/create',
      extra: {
        'year': _selectedYear,
        'month': _selectedMonth,
      },
    );
    _refresh();
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
      _loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orçamentos $_selectedMonth/$_selectedYear'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateBudget,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<BudgetModel>>(
        future: _budgetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando orçamentos...',
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
                    title: 'Nenhum orçamento cadastrado',
                    subtitle: 'Crie um orçamento para acompanhar seu planejamento.',
                    icon: Icons.savings_outlined,
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

                return BudgetCard(
                  year: item.year,
                  month: item.month,
                  categoryId: item.categoryId,
                  plannedAmount: _formatAmount(item.plannedAmount),
                  onTap: () async {
                    await context.push('/budgets/edit', extra: item);
                    _refresh();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}