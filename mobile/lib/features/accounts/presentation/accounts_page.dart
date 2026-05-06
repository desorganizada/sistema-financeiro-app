// lib/features/accounts/presentation/accounts_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../data/account_model.dart';
import '../data/account_service.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountService _accountService = AccountService();

  List<AccountModel> _accounts = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accounts = await _accountService.getAccountsWithOriginalBalance();
      
      if (!mounted) return;
      
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadAccounts();
  }

  Future<void> _confirmDeleteAccount(AccountModel account) async {
    final hasBalance = (account.balance != null && account.balance!.abs() > 0);
    final hasTransactions = (account.income != null && account.income! > 0) ||
        (account.expense != null && account.expense! > 0) ||
        (account.investment != null && account.investment! > 0);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir a conta "${account.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (hasBalance || hasTransactions)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Esta conta possui movimentações!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Todas as transações associadas a esta conta também serão excluídas.',
                            style: TextStyle(fontSize: 12, color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Esta ação NÃO pode ser desfeita.',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMedium,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount(account);
    }
  }

  Future<void> _deleteAccount(AccountModel account) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _accountService.deleteAccount(account.id);
      
      if (!mounted) return;
      
      await _loadAccounts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Conta "${account.name}" excluída com sucesso!'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryTerracota,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Erro ao excluir conta: ${e.toString().replaceFirst('Exception: ', '')}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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

  String _getAccountTypeName(String type) {
    switch (type) {
      case 'corrente':
        return 'Conta Corrente';
      case 'carteira':
        return 'Carteira';
      case 'cartao':
        return 'Cartão de Crédito';
      case 'investimento':
        return 'Investimento';
      default:
        return type;
    }
  }

  String _getAccountIcon(String type) {
    switch (type) {
      case 'corrente':
        return '🏦';
      case 'carteira':
        return '👛';
      case 'cartao':
        return '💳';
      case 'investimento':
        return '📈';
      default:
        return '💰';
    }
  }

  Future<void> _goToCreateAccount() async {
    await context.push('/accounts/create');
    await _refresh();
  }

  Future<void> _goToEditAccount(AccountModel account) async {
    await context.push('/accounts/edit', extra: account);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Minhas Contas'),
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
        onPressed: _goToCreateAccount,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const AppLoading(message: 'Carregando contas...')
          : _error != null
              ? AppErrorState(
                  message: _error!,
                  onRetry: _refresh,
                )
              : _accounts.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 120),
                          AppEmptyState(
                            title: 'Nenhuma conta cadastrada',
                            subtitle: 'Clique no botão + para criar sua primeira conta',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _accounts.length,
                            itemBuilder: (context, index) {
                              final account = _accounts[index];
                              final balance = account.balance ?? 0.0;
                              final isPositive = balance >= 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.surfaceSand,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    InkWell(
                                      onTap: () => _goToEditAccount(account),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            // 🔧 RESPONSIVO: Em telas pequenas, empilha verticalmente
                                            if (constraints.maxWidth < 450) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Linha superior: ícone + nome + tipo
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: _getTypeColor(account.type).withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            _getAccountIcon(account.type),
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
                                                              account.name,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              _getAccountTypeName(account.type),
                                                              style: TextStyle(
                                                                color: AppColors.textMedium,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Linha inferior: saldo
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Saldo:',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.textMedium,
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatCurrency(balance, account.currency),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: isPositive ? AppColors.success : AppColors.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'Saldo original',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors.textMedium,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            
                                            // 🔧 LAYOUT DESKTOP: mantém original lado a lado
                                            return Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: _getTypeColor(account.type).withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      _getAccountIcon(account.type),
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
                                                        account.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _getAccountTypeName(account.type),
                                                        style: TextStyle(
                                                          color: AppColors.textMedium,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      _formatCurrency(balance, account.currency),
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: isPositive ? AppColors.success : AppColors.error,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'Saldo original',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors.textMedium,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Divider(height: 0, color: AppColors.borderSand),
                                    InkWell(
                                      onTap: () => _confirmDeleteAccount(account),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.05),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: AppColors.error,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Excluir conta',
                                              style: TextStyle(
                                                color: AppColors.error,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (_isDeleting)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Excluindo conta...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'corrente':
        return AppColors.primaryTerracota;
      case 'carteira':
        return AppColors.warning;
      case 'cartao':
        return AppColors.info;
      case 'investimento':
        return AppColors.success;
      default:
        return AppColors.textMedium;
    }
  }
}