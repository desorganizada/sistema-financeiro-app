import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/data/user_model.dart';
import '../../dashboard/data/dashboard_service.dart';
import '../../dashboard/data/dashboard_summary_model.dart';
import '../../accounts/data/account_service.dart';
import '../../accounts/data/account_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  final AccountService _accountService = AccountService();

  late Future<DashboardSummaryModel> _summaryFuture;
  UserModel? _user;
  List<AccountModel> _accounts = []; // 👈 MUDEI PARA List<AccountModel>
  bool _isLoadingUser = true;
  String? _userError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadUser();
    _loadAccounts();
  }

  void _loadSummary() {
    final now = DateTime.now();
    _summaryFuture = _dashboardService.getSummary(
      year: now.year,
      month: now.month,
    );
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _accountService.getAccountsWithOriginalBalance();
      if (mounted) {
        setState(() {
          _accounts = accounts;
        });
      }
    } catch (e) {
      print('Erro ao carregar contas: $e');
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getMe();

      if (!mounted) return;
      setState(() {
        _user = user;
        _userError = null;
        _isLoadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _reloadHomeData() async {
    setState(() {
      _isLoadingUser = true;
      _loadSummary();
    });

    await _loadUser();
    await _loadAccounts();
    await _summaryFuture;
  }

  Future<void> _refreshSummary() async {
    await _reloadHomeData();
  }

  Future<void> _openProfile() async {
    await context.push('/profile');

    if (!mounted) return;
    await _reloadHomeData();
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearToken();

    if (!context.mounted) return;
    context.go('/login');
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

  String _getCurrencyFlag(String currency) {
    switch (currency) {
      case 'BRL':
        return '🇧🇷';
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'NZD':
        return '🇳🇿';
      case 'AED':
        return '🇦🇪';
      default:
        return '💰';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: AppLoading(
          message: 'Carregando usuário...',
        ),
      );
    }

    if (_userError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_userError!),
          ),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Sistema Financeiro'),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_user!.isAdmin)
            IconButton(
              onPressed: () => context.push('/admin/users'),
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Administração',
            ),
          IconButton(
            onPressed: _refreshSummary,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/create'),
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova transação'),
      ),
      body: FutureBuilder<DashboardSummaryModel>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando resumo financeiro...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refreshSummary,
            );
          }

          final summary = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshSummary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeHeader(
                    userName: _user!.name,
                    baseCurrency: _user!.baseCurrency,
                  ),
                  const SizedBox(height: 20),

                  _BalanceHighlightCard(
                    balance: _formatCurrency(summary.balance, _user!.baseCurrency),
                    transactionsCount: summary.transactionsCount,
                    currency: _user!.baseCurrency,
                    accounts: _accounts,
                  ),
                  const SizedBox(height: 20),

                  const _SectionHeader(
                    title: 'Resumo do mês',
                    subtitle: 'Acompanhe rapidamente seus principais números',
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniSummaryCard(
                          title: 'Receitas',
                          value: _formatCurrency(summary.income, _user!.baseCurrency),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniSummaryCard(
                          title: 'Despesas',
                          value: _formatCurrency(summary.expense, _user!.baseCurrency),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniSummaryCard(
                          title: 'Investimentos',
                          value: _formatCurrency(summary.investment, _user!.baseCurrency),
                          icon: Icons.trending_up,
                          iconColor: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniSummaryCard(
                          title: 'Transações',
                          value: summary.transactionsCount.toString(),
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const _SectionHeader(
                    title: 'Ações rápidas',
                    subtitle: 'Os acessos mais usados no seu dia a dia',
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 108,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionButton(
                          icon: Icons.swap_horiz,
                          label: 'Transações',
                          onTap: () => context.push('/transactions'),
                          iconColor: AppColors.primaryTerracota,
                        ),
                        _QuickActionButton(
                          icon: Icons.account_balance,
                          label: 'Contas',
                          onTap: () => context.push('/accounts'),
                          iconColor: AppColors.lightTerracota,
                        ),
                        _QuickActionButton(
                          icon: Icons.category_outlined,
                          label: 'Categorias',
                          onTap: () => context.push('/categories'),
                          iconColor: AppColors.warning,
                        ),
                        _QuickActionButton(
                          icon: Icons.bar_chart,
                          label: 'Dashboard',
                          onTap: () => context.push('/dashboard-analytics'),
                          iconColor: AppColors.info,
                        ),
                        _QuickActionButton(
                          icon: Icons.currency_exchange,
                          label: 'Câmbio',
                          onTap: () => context.push('/exchange'),
                          iconColor: AppColors.success,
                        ),
                        if (_user!.isAdmin)
                          _QuickActionButton(
                            icon: Icons.admin_panel_settings,
                            label: 'Admin',
                            onTap: () => context.push('/admin/users'),
                            iconColor: AppColors.error,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const _SectionHeader(
                    title: 'Análises',
                    subtitle: 'Visualize relatórios e indicadores',
                  ),
                  const SizedBox(height: 12),

                  _ModuleCard(
                    title: 'Resumo por categoria',
                    subtitle: 'Veja para onde seu dinheiro está indo',
                    icon: Icons.pie_chart_outline,
                    iconColor: AppColors.primaryTerracota,
                    onTap: () => context.push('/dashboard-by-category'),
                  ),
                  const SizedBox(height: 12),
                  _ModuleCard(
                    title: 'Evolução mensal',
                    subtitle: 'Acompanhe o comportamento ao longo do ano',
                    icon: Icons.show_chart,
                    iconColor: AppColors.lightTerracota,
                    onTap: () => context.push('/monthly-evolution'),
                  ),
                  const SizedBox(height: 12),
                  _ModuleCard(
                    title: 'Dashboard analítico',
                    subtitle: 'Tenha uma visão mais completa das finanças',
                    icon: Icons.bar_chart,
                    iconColor: AppColors.primaryTerracota,
                    onTap: () => context.push('/dashboard-analytics'),
                  ),
                  const SizedBox(height: 24),

                  const _SectionHeader(
                    title: 'Gestão financeira',
                    subtitle: 'Módulos principais do sistema',
                  ),
                  const SizedBox(height: 16),

                  _MainModulesGrid(
                    user: _user!,
                    onProfileTap: _openProfile,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------- WIDGETS ATUALIZADOS ----------------------

class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final String baseCurrency;

  const _WelcomeHeader({
    required this.userName,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $userName 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Moeda base: $baseCurrency',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
}

class _BalanceHighlightCard extends StatelessWidget {
  final String balance;
  final int transactionsCount;
  final String currency;
  final List<AccountModel> accounts;

  const _BalanceHighlightCard({
    required this.balance,
    required this.transactionsCount,
    required this.currency,
    required this.accounts,
  });

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

  String _getCurrencyFlag(String currency) {
    switch (currency) {
      case 'BRL':
        return '🇧🇷';
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'NZD':
        return '🇳🇿';
      case 'AED':
        return '🇦🇪';
      default:
        return '💰';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agrupa saldos por moeda
    Map<String, double> balancesByCurrency = {};
    for (var account in accounts) {
      String curr = account.currency;
      double bal = account.balance ?? 0.0;
      balancesByCurrency[curr] = (balancesByCurrency[curr] ?? 0) + bal;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTerracota,
            AppColors.lightTerracota,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTerracota.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo atual',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          // Saldos por moeda
          if (balancesByCurrency.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldos por moeda:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: balancesByCurrency.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCurrencyFlag(entry.key),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.key}: ${_formatCurrency(entry.value, entry.key)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$transactionsCount transações no mês',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MiniSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSand,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSand),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSand,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSand),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: AppColors.textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- GRID DE MÓDULOS PRINCIPAIS ----------------------

class _MainModulesGrid extends StatelessWidget {
  final UserModel user;
  final VoidCallback onProfileTap;

  const _MainModulesGrid({
    required this.user,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modules = [
      {'title': 'Contas', 'subtitle': 'Gerencie suas contas cadastradas', 'icon': Icons.account_balance, 'route': '/accounts', 'color': AppColors.primaryTerracota},
      {'title': 'Categorias', 'subtitle': 'Organize receitas, despesas e investimentos', 'icon': Icons.category_outlined, 'route': '/categories', 'color': AppColors.warning},
      {'title': 'Transações', 'subtitle': 'Cadastre e acompanhe movimentações', 'icon': Icons.swap_horiz, 'route': '/transactions', 'color': AppColors.success},
      {'title': 'Orçamentos', 'subtitle': 'Planeje seus limites de gastos', 'icon': Icons.savings_outlined, 'route': '/budgets', 'color': AppColors.info},
      {'title': 'Planejado vs realizado', 'subtitle': 'Compare o que foi previsto com o que aconteceu', 'icon': Icons.analytics_outlined, 'route': '/budget-vs-actual', 'color': AppColors.lightTerracota},
      {'title': 'Câmbio', 'subtitle': 'Converta valores e acompanhe moedas', 'icon': Icons.currency_exchange, 'route': '/exchange', 'color': AppColors.primaryTerracota},
      {'title': 'Fechamento mensal', 'subtitle': 'Controle o encerramento de cada mês', 'icon': Icons.lock_clock_outlined, 'route': '/monthly-closures', 'color': AppColors.textDark},
      if (user.isAdmin) {'title': 'Administração de usuários', 'subtitle': 'Gerencie usuários e permissões do sistema', 'icon': Icons.admin_panel_settings, 'route': '/admin/users', 'color': AppColors.error},
      {'title': 'Perfil', 'subtitle': 'Ajuste seus dados e preferências', 'icon': Icons.person_outline, 'route': '/profile', 'color': AppColors.textMedium, 'isProfile': true},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.35,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: modules.length,
          itemBuilder: (_, index) {
            final module = modules[index];
            return _ModuleGridCard(
              title: module['title'] as String,
              subtitle: module['subtitle'] as String,
              icon: module['icon'] as IconData,
              iconColor: module['color'] as Color,
              onTap: module['isProfile'] == true
                  ? onProfileTap
                  : () => context.push(module['route'] as String),
            );
          },
        );
      },
    );
  }
}

class _ModuleGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModuleGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSand,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSand),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}