import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
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
  int _selectedYear = DateTime.now().year;
  String _selectedChartType = 'balance'; // balance, income, expense, investment

  @override
  void initState() {
    super.initState();
    _loadEvolution();
  }

  void _loadEvolution() {
    _evolutionFuture = _dashboardService.getMonthlyEvolution(
      year: _selectedYear,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadEvolution();
    });
    await _evolutionFuture;
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear += delta;
      _loadEvolution();
    });
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  Color _getChartColor(String type) {
    switch (type) {
      case 'income':
        return AppColors.success;
      case 'expense':
        return AppColors.error;
      case 'investment':
        return AppColors.info;
      case 'balance':
      default:
        return AppColors.primaryTerracota;
    }
  }

  String _getChartTitle(String type) {
    switch (type) {
      case 'income':
        return 'Receitas';
      case 'expense':
        return 'Despesas';
      case 'investment':
        return 'Investimentos';
      case 'balance':
      default:
        return 'Saldo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Evolução Mensal'),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<MonthlyEvolutionModel>>(
        future: _evolutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'Carregando evolução mensal...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty || items.every((i) => i.balance == 0 && i.income == 0 && i.expense == 0 && i.investment == 0)) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de ano
                  _buildYearSelector(),
                  const SizedBox(height: 20),
                  
                  // Seletor de tipo de gráfico
                  _buildChartTypeSelector(),
                  const SizedBox(height: 20),
                  
                  // Gráfico principal
                  _buildMainChart(items),
                  const SizedBox(height: 24),
                  
                  // Cards de resumo anual
                  _buildAnnualSummary(items),
                  const SizedBox(height: 24),
                  
                  // Tabela de dados
                  _buildDataTable(items),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeYear(-1),
            icon: Icon(Icons.chevron_left, color: AppColors.primaryTerracota),
          ),
          Text(
            _selectedYear.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          IconButton(
            onPressed: () => _changeYear(1),
            icon: Icon(Icons.chevron_right, color: AppColors.primaryTerracota),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    final types = [
      {'value': 'balance', 'label': '💰 Saldo', 'color': AppColors.primaryTerracota},
      {'value': 'income', 'label': '📈 Receitas', 'color': AppColors.success},
      {'value': 'expense', 'label': '📉 Despesas', 'color': AppColors.error},
      {'value': 'investment', 'label': '📊 Investimentos', 'color': AppColors.info},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedChartType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedChartType = type['value'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (type['color'] as Color).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? type['color'] as Color
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainChart(List<MonthlyEvolutionModel> items) {
    final chartColor = _getChartColor(_selectedChartType);
    
    return Container(
      height: 280,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: chartColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getChartTitle(_selectedChartType),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: chartColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue(items) / 5,
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
                        if (index >= 0 && index < items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _monthLabel(index + 1),
                              style: TextStyle(
                                fontSize: 10,
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'R\$ ${value.toInt()}',
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
                    spots: _getSpots(items),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: chartColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: _getMinValue(items),
                maxY: _getMaxValue(items),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(List<MonthlyEvolutionModel> items) {
    List<FlSpot> spots = [];
    for (int i = 0; i < items.length; i++) {
      double value = 0;
      switch (_selectedChartType) {
        case 'income':
          value = items[i].income;
          break;
        case 'expense':
          value = items[i].expense;
          break;
        case 'investment':
          value = items[i].investment;
          break;
        case 'balance':
        default:
          value = items[i].balance;
          break;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _getMaxValue(List<MonthlyEvolutionModel> items) {
    double maxValue = 0;
    for (var item in items) {
      switch (_selectedChartType) {
        case 'income':
          maxValue = maxValue > item.income ? maxValue : item.income;
          break;
        case 'expense':
          maxValue = maxValue > item.expense ? maxValue : item.expense;
          break;
        case 'investment':
          maxValue = maxValue > item.investment ? maxValue : item.investment;
          break;
        case 'balance':
        default:
          maxValue = maxValue > item.balance ? maxValue : item.balance;
          break;
      }
    }
    return maxValue == 0 ? 100 : maxValue + (maxValue * 0.1);
  }

  double _getMinValue(List<MonthlyEvolutionModel> items) {
    double minValue = 0;
    for (var item in items) {
      switch (_selectedChartType) {
        case 'expense':
          if (item.expense < minValue) minValue = item.expense;
          break;
        case 'balance':
          if (item.balance < minValue) minValue = item.balance;
          break;
        default:
          break;
      }
    }
    return minValue < 0 ? minValue - (minValue.abs() * 0.1) : 0;
  }

  Widget _buildAnnualSummary(List<MonthlyEvolutionModel> items) {
    double totalIncome = 0;
    double totalExpense = 0;
    double totalInvestment = 0;
    double finalBalance = items.isNotEmpty ? items.last.balance : 0;

    for (var item in items) {
      totalIncome += item.income;
      totalExpense += item.expense;
      totalInvestment += item.investment;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo Anual',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Receitas',
                  value: _formatCurrency(totalIncome),
                  color: AppColors.success,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Despesas',
                  value: _formatCurrency(totalExpense),
                  color: AppColors.error,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Investimentos',
                  value: _formatCurrency(totalInvestment),
                  color: AppColors.info,
                  icon: Icons.show_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Saldo Final',
                  value: _formatCurrency(finalBalance),
                  color: AppColors.primaryTerracota,
                  icon: Icons.account_balance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<MonthlyEvolutionModel> items) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dados Mensais',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => AppColors.primaryTerracota.withOpacity(0.1),
              ),
              columns: const [
                DataColumn(label: Text('Mês')),
                DataColumn(label: Text('Receitas')),
                DataColumn(label: Text('Despesas')),
                DataColumn(label: Text('Invest.')),
                DataColumn(label: Text('Saldo')),
              ],
              rows: items.where((item) => 
                item.income != 0 || item.expense != 0 || item.investment != 0 || item.balance != 0
              ).map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(_monthLabel(item.month))),
                    DataCell(Text(_formatCurrency(item.income), style: TextStyle(color: AppColors.success))),
                    DataCell(Text(_formatCurrency(item.expense), style: TextStyle(color: AppColors.error))),
                    DataCell(Text(_formatCurrency(item.investment), style: TextStyle(color: AppColors.info))),
                    DataCell(Text(_formatCurrency(item.balance), style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.balance >= 0 ? AppColors.success : AppColors.error,
                    ))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}