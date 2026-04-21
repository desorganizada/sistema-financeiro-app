import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/transaction_card.dart';
import '../../accounts/data/account_model.dart';
import '../../accounts/data/account_service.dart';
import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/transaction_list_response.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  late Future<TransactionListResponse> _transactionsFuture;

  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];

  bool _isFilterDataLoading = true;

  String? _selectedType;
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedAccountId;
  int? _selectedCategoryId;

  int _limit = 20;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isFilterDataLoading = true;
    });

    try {
      final accounts = await _accountService.getAccounts();
      final categories = await _categoryService.getCategories();

      _accounts = accounts;
      _categories = categories;

      _loadTransactions();
    } catch (e) {
      _transactionsFuture = Future.error(e);
    } finally {
      if (!mounted) return;

      setState(() {
        _isFilterDataLoading = false;
      });
    }
  }

  void _loadTransactions() {
    _transactionsFuture = _transactionService.getTransactions(
      year: _selectedYear,
      month: _selectedMonth,
      categoryId: _selectedCategoryId,
      accountId: _selectedAccountId,
      type: _selectedType,
      limit: _limit,
      offset: _offset,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _offset = 0;
      _loadTransactions();
    });

    await _transactionsFuture;
  }

  Future<void> _goToCreateTransaction() async {
    await context.push('/transactions/create');
    await _refresh();
  }

  void _applyFilters() {
    setState(() {
      _offset = 0;
      _loadTransactions();
    });
  }

  void _clearFilters() {
    final now = DateTime.now();

    setState(() {
      _selectedType = null;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedAccountId = null;
      _selectedCategoryId = null;
      _offset = 0;
      _loadTransactions();
    });
  }

  void _nextPage(TransactionListResponse response) {
    if (_offset + _limit >= response.total) return;

    setState(() {
      _offset += _limit;
      _loadTransactions();
    });
  }

  void _previousPage() {
    if (_offset == 0) return;

    setState(() {
      _offset -= _limit;
      if (_offset < 0) {
        _offset = 0;
      }
      _loadTransactions();
    });
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  List<DropdownMenuItem<String?>> _typeItems() {
    return const [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('Todos'),
      ),
      DropdownMenuItem<String?>(
        value: 'income',
        child: Text('Receitas'),
      ),
      DropdownMenuItem<String?>(
        value: 'expense',
        child: Text('Despesas'),
      ),
      DropdownMenuItem<String?>(
        value: 'investment',
        child: Text('Investimentos'),
      ),
    ];
  }

  List<DropdownMenuItem<int?>> _yearItems() {
    final now = DateTime.now();
    final years = List.generate(6, (index) => now.year - 2 + index);

    return years
        .map(
          (year) => DropdownMenuItem<int?>(
            value: year,
            child: Text(year.toString()),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<int?>> _monthItems() {
    return const [
      DropdownMenuItem<int?>(value: 1, child: Text('Janeiro')),
      DropdownMenuItem<int?>(value: 2, child: Text('Fevereiro')),
      DropdownMenuItem<int?>(value: 3, child: Text('Março')),
      DropdownMenuItem<int?>(value: 4, child: Text('Abril')),
      DropdownMenuItem<int?>(value: 5, child: Text('Maio')),
      DropdownMenuItem<int?>(value: 6, child: Text('Junho')),
      DropdownMenuItem<int?>(value: 7, child: Text('Julho')),
      DropdownMenuItem<int?>(value: 8, child: Text('Agosto')),
      DropdownMenuItem<int?>(value: 9, child: Text('Setembro')),
      DropdownMenuItem<int?>(value: 10, child: Text('Outubro')),
      DropdownMenuItem<int?>(value: 11, child: Text('Novembro')),
      DropdownMenuItem<int?>(value: 12, child: Text('Dezembro')),
    ];
  }

  Widget _buildScrollableError(Object error) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 120),
        children: [
          SizedBox(
            height: 260,
            child: AppErrorState(
              message: error.toString(),
              onRetry: _refresh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableEmpty() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 120),
        children: const [
          SizedBox(
            height: 260,
            child: AppEmptyState(
              title: 'Nenhuma transação encontrada',
              subtitle: 'Cadastre uma transação ou ajuste os filtros.',
              icon: Icons.swap_horiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionListResponse response) {
    final List<TransactionModel> items = response.items;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionCard(
                description: item.description,
                type: item.type,
                date: item.date,
                amount: _formatAmount(item.amountConverted),
                currency: item.originalCurrency,
                onTap: () async {
                  await context.push(
                    '/transactions/edit',
                    extra: item,
                  );
                  await _refresh();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _offset == 0 ? null : _previousPage,
                  child: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mostrando ${response.items.length} de ${response.total}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_offset + _limit >= response.total)
                      ? null
                      : () => _nextPage(response),
                  child: const Text('Próxima'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Tipo',
            border: OutlineInputBorder(),
          ),
          items: _typeItems(),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          value: _selectedYear,
          decoration: const InputDecoration(
            labelText: 'Ano',
            border: OutlineInputBorder(),
          ),
          items: _yearItems(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          value: _selectedMonth,
          decoration: const InputDecoration(
            labelText: 'Mês',
            border: OutlineInputBorder(),
          ),
          items: _monthItems(),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          value: _selectedAccountId,
          decoration: const InputDecoration(
            labelText: 'Conta',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todas'),
            ),
            ..._accounts.map(
              (account) => DropdownMenuItem<int?>(
                value: account.id,
                child: Text(account.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todas'),
            ),
            ..._categories.map(
              (category) => DropdownMenuItem<int?>(
                value: category.id,
                child: Text(category.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFilterDataLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transações'),
        ),
        body: const AppLoading(
          message: 'Carregando filtros...',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateTransaction,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<TransactionListResponse>(
                      future: _transactionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const AppLoading(
                            message: 'Carregando transações...',
                          );
                        }

                        if (snapshot.hasError) {
                          return _buildScrollableError(snapshot.error!);
                        }

                        if (!snapshot.hasData) {
                          return _buildScrollableError('Nenhum dado foi retornado.');
                        }

                        final response = snapshot.data!;

                        if (response.items.isEmpty) {
                          return _buildScrollableEmpty();
                        }

                        return _buildTransactionList(response);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}