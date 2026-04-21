import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/account_balance_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../data/account_balance_model.dart';
import '../data/account_model.dart';
import '../data/account_service.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountService _accountService = AccountService();

  Future<List<AccountBalanceModel>>? _balancesFuture;
  List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadBalances() {
    _balancesFuture = _accountService.getAccountBalances();
  }

  Future<void> _loadAll() async {
    try {
      final accounts = await _accountService.getAccounts();

      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _loadBalances();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _accounts = [];
        _balancesFuture = Future.error(e);
      });
    }
  }

  Future<void> _refresh() async {
    await _loadAll();
    if (_balancesFuture != null) {
      await _balancesFuture;
    }
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  Future<void> _goToCreateAccount() async {
    await context.push('/accounts/create');
    await _refresh();
  }

  AccountModel? _findAccountById(int accountId) {
    try {
      return _accounts.firstWhere((account) => account.id == accountId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balancesFuture = _balancesFuture;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateAccount,
        child: const Icon(Icons.add),
      ),
      body: balancesFuture == null
          ? const AppLoading(
              message: 'Carregando contas...',
            )
          : FutureBuilder<List<AccountBalanceModel>>(
              future: balancesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoading(
                    message: 'Carregando contas...',
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
                          title: 'Nenhuma conta cadastrada',
                          subtitle: 'Crie sua primeira conta para começar.',
                          icon: Icons.account_balance_wallet_outlined,
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
                      final account = _findAccountById(item.accountId);

                      return AccountBalanceCard(
                        name: item.accountName,
                        currency: item.currency,
                        initialBalance: _formatCurrency(item.balance),
                        income: _formatCurrency(item.income),
                        expense: _formatCurrency(item.expense),
                        investment: _formatCurrency(item.investment),
                        balance: _formatCurrency(item.balance),
                        onTap: account == null
                            ? null
                            : () async {
                                await context.push('/accounts/edit', extra: account);
                                await _refresh();
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