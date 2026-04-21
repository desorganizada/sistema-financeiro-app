import 'package:flutter/material.dart';

import '../../../shared/widgets/monthly_evolution_tile.dart';
import '../data/dashboard_service.dart';
import '../data/monthly_evolution_model.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

class MonthlyEvolutionPage extends StatefulWidget {
  const MonthlyEvolutionPage({super.key});

  @override
  State<MonthlyEvolutionPage> createState() => _MonthlyEvolutionPageState();
}

class _MonthlyEvolutionPageState extends State<MonthlyEvolutionPage> {
  final DashboardService _dashboardService = DashboardService();

  late Future<List<MonthlyEvolutionModel>> _evolutionFuture;

  @override
  void initState() {
    super.initState();
    _loadEvolution();
  }

  void _loadEvolution() {
    final now = DateTime.now();
    _evolutionFuture = _dashboardService.getMonthlyEvolution(
      year: now.year,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadEvolution();
    });

    await _evolutionFuture;
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  String _monthLabel(int month) {
    const months = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    if (month < 1 || month > 12) return 'Mês inválido';
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolução Mensal'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<MonthlyEvolutionModel>>(
        future: _evolutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando evolução mensal...',
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
                    subtitle: 'Ainda não há movimentações para exibir a evolução mensal.',
                    icon: Icons.show_chart,
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

                return MonthlyEvolutionTile(
                  monthLabel: _monthLabel(item.month),
                  income: _formatCurrency(item.income),
                  expense: _formatCurrency(item.expense),
                  investment: _formatCurrency(item.investment),
                  balance: _formatCurrency(item.balance),
                );
              },
            ),
          );
        },
      ),
    );
  }
}