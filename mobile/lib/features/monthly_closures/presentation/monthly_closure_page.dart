import 'package:flutter/material.dart';

import '../data/monthly_closure_model.dart';
import '../data/monthly_closure_service.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

class MonthlyClosurePage extends StatefulWidget {
  const MonthlyClosurePage({super.key});

  @override
  State<MonthlyClosurePage> createState() => _MonthlyClosurePageState();
}

class _MonthlyClosurePageState extends State<MonthlyClosurePage> {
  final MonthlyClosureService _service = MonthlyClosureService();

  late int _selectedYear;
  late int _selectedMonth;

  MonthlyClosureModel? _closure;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadClosure();
  }

  Future<void> _loadClosure() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final closure = await _service.getClosure(
        year: _selectedYear,
        month: _selectedMonth,
      );

      setState(() {
        _closure = closure;
      });
    } catch (e) {
      if (e.toString().contains('NOT_FOUND')) {
        setState(() {
          _closure = null;
        });
      } else {
        setState(() {
          _message = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadClosure();
  }

  Future<void> _closeMonth() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _service.closeMonth(
        year: _selectedYear,
        month: _selectedMonth,
      );
      await _loadClosure();
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _reopenMonth() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _service.reopenMonth(
        year: _selectedYear,
        month: _selectedMonth,
      );
      await _loadClosure();
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
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
    });

    await _loadClosure();
  }

  String _fmt(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final isClosed = _closure != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Fechamento $_selectedMonth/$_selectedYear'),
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
      body: _isLoading
          ? const AppLoading(
              message: 'Carregando fechamento mensal...',
            )
          : _message != null
              ? AppErrorState(
                  message: _message!,
                  onRetry: _refresh,
                )
              : _closure == null
                  ? RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          SizedBox(height: 120),
                          AppEmptyState(
                            title: 'Nenhum dado encontrado',
                            subtitle: 'Este mês ainda não possui fechamento realizado.',
                            icon: Icons.lock_open_outlined,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                isClosed
                                    ? 'Status: mês fechado'
                                    : 'Status: mês aberto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isClosed ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Receitas: ${_fmt(_closure!.income)}'),
                                  Text('Despesas: ${_fmt(_closure!.expense)}'),
                                  Text(
                                    'Investimentos: ${_fmt(_closure!.investment)}',
                                  ),
                                  Text(
                                    'Saldo: ${_fmt(_closure!.balance)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Transações: ${_closure!.transactionsCount}',
                                  ),
                                  Text('Fechado em: ${_closure!.closedAt}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _reopenMonth,
                              child: const Text('Reabrir mês'),
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: !_isLoading && _closure == null
          ? FloatingActionButton.extended(
              onPressed: _closeMonth,
              icon: const Icon(Icons.lock),
              label: const Text('Fechar mês'),
            )
          : null,
    );
  }
}