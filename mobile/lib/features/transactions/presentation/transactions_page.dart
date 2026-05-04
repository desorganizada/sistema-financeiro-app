import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../data/transaction_list_response.dart';
import '../data/transaction_service.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionService _transactionService = TransactionService();

  late Future<TransactionListResponse> _transactionsFuture;

  String _selectedType = 'all';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = _transactionService.getTransactions(
      year: _selectedYear,
      month: _selectedMonth,
      type: _selectedType == 'all' ? null : _selectedType,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadTransactions();
    });
    await _transactionsFuture;
  }

  void _applyFilters() {
    setState(() {
      _loadTransactions();
    });
  }

  String _formatCurrency(double value, String currency) {
    switch (currency) {
      case 'BRL':
        return 'R\$ ${value.toStringAsFixed(2)}';
      case 'USD':
        return 'US\$ ${value.toStringAsFixed(2)}';
      case 'EUR':
        return '€ ${value.toStringAsFixed(2)}';
      case 'GBP':
        return '£ ${value.toStringAsFixed(2)}';
      case 'NZD':
        return 'NZ\$ ${value.toStringAsFixed(2)}';
      case 'AED':
        return 'د.إ ${value.toStringAsFixed(2)}';
      default:
        return '${value.toStringAsFixed(2)} $currency';
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'income':
        return '💰';
      case 'expense':
        return '💸';
      case 'investment':
        return '📈';
      default:
        return '📝';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'income':
        return AppColors.success;
      case 'expense':
        return AppColors.error;
      case 'investment':
        return AppColors.info;
      default:
        return AppColors.textMedium;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'income':
        return 'Receita';
      case 'expense':
        return 'Despesa';
      case 'investment':
        return 'Investimento';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Transações'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/transactions/create');
          await _refresh();
        },
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Todos',
                        value: 'all',
                        groupValue: _selectedType,
                        onSelected: (value) {
                          setState(() {
                            _selectedType = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Receitas',
                        value: 'income',
                        groupValue: _selectedType,
                        onSelected: (value) {
                          setState(() {
                            _selectedType = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Despesas',
                        value: 'expense',
                        groupValue: _selectedType,
                        onSelected: (value) {
                          setState(() {
                            _selectedType = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Investimentos',
                        value: 'investment',
                        groupValue: _selectedType,
                        onSelected: (value) {
                          setState(() {
                            _selectedType = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildYearDropdown(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMonthDropdown(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de transações
          Expanded(
            child: FutureBuilder<TransactionListResponse>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoading(message: 'Carregando transações...');
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }

                final response = snapshot.data!;
                final transactions = response.items;

                if (transactions.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: const [
                        SizedBox(height: 120),
                        AppEmptyState(
                          title: 'Nenhuma transação encontrada',
                          subtitle: 'Crie sua primeira transação para começar a organizar suas finanças.',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      
                      // Mostra o valor convertido (amount_converted) em vez do original
                      final convertedAmount = transaction.amountConverted ?? transaction.amountOriginal;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: AppColors.surfaceSand,
                        child: InkWell(
                          onTap: () async {
                            await context.push('/transactions/edit', extra: transaction);
                            await _refresh();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(transaction.type).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getTypeIcon(transaction.type),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        transaction.date,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(transaction.type).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getTypeName(transaction.type),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _getTypeColor(transaction.type),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(convertedAmount, 'BRL'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _getTypeColor(transaction.type),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Original: ${transaction.amountOriginal.toStringAsFixed(2)} ${transaction.originalCurrency}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onSelected,
  }) {
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        backgroundColor: AppColors.surfaceSand,
        selectedColor: AppColors.primaryTerracota.withOpacity(0.2),
        checkmarkColor: AppColors.primaryTerracota,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryTerracota : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.primaryTerracota : AppColors.borderSand,
          ),
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);
    
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: InputDecoration(
        labelText: 'Ano',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedYear = value;
            _applyFilters();
          });
        }
      },
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: InputDecoration(
        labelText: 'Mês',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: List.generate(12, (index) {
        final month = index + 1;
        return DropdownMenuItem(
          value: month,
          child: Text(_getMonthName(month)),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedMonth = value;
            _applyFilters();
          });
        }
      },
    );
  }
}