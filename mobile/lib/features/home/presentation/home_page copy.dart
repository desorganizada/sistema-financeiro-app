import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/home_menu_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/data/user_model.dart';
import '../../dashboard/data/dashboard_service.dart';
import '../../dashboard/data/dashboard_summary_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();

  late Future<DashboardSummaryModel> _summaryFuture;
  UserModel? _user;
  bool _isLoadingUser = true;
  String? _userError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadUser();
  }

  void _loadSummary() {
    final now = DateTime.now();
    _summaryFuture = _dashboardService.getSummary(
      year: now.year,
      month: now.month,
    );
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getMe();

      if (!mounted) return;
      setState(() {
        _user = user;
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

  Future<void> _refreshSummary() async {
    setState(() {
      _loadSummary();
    });

    await _summaryFuture;
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearToken();

    if (!context.mounted) return;
    context.go('/login');
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userError != null) {
      return Scaffold(
        body: Center(
          child: Text(_userError!),
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
      appBar: AppBar(
        title: const Text('Sistema Financeiro'),
        actions: [
          IconButton(
            onPressed: _refreshSummary,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionTitle(
                  title: 'Olá, ${_user!.name}',
                  subtitle: 'Moeda base: ${_user!.baseCurrency}',
                ),
                const SizedBox(height: 24),

                const SectionTitle(
                  title: 'Resumo do mês',
                  subtitle: 'Visão geral das suas finanças',
                ),
                const SizedBox(height: 12),

                SummaryCard(
                  title: 'Receitas',
                  value: _formatCurrency(summary.income),
                ),
                const SizedBox(height: 12),

                SummaryCard(
                  title: 'Despesas',
                  value: _formatCurrency(summary.expense),
                ),
                const SizedBox(height: 12),

                SummaryCard(
                  title: 'Investimentos',
                  value: _formatCurrency(summary.investment),
                ),
                const SizedBox(height: 12),

                SummaryCard(
                  title: 'Saldo',
                  value: _formatCurrency(summary.balance),
                ),
                const SizedBox(height: 12),

                SummaryCard(
                  title: 'Transações',
                  value: summary.transactionsCount.toString(),
                ),
                const SizedBox(height: 24),

                const SectionTitle(
                  title: 'Atalhos',
                  subtitle: 'Acesse rapidamente os módulos do sistema',
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Resumo por categoria',
                  icon: Icons.pie_chart_outline,
                  onTap: () => context.push('/dashboard-by-category'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Evolução mensal',
                  icon: Icons.show_chart,
                  onTap: () => context.push('/monthly-evolution'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Dashboard analítico',
                  icon: Icons.bar_chart,
                  onTap: () => context.push('/dashboard-analytics'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Contas',
                  icon: Icons.account_balance,
                  onTap: () => context.push('/accounts'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Categorias',
                  icon: Icons.category_outlined,
                  onTap: () => context.push('/categories'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Transações',
                  icon: Icons.swap_horiz,
                  onTap: () => context.push('/transactions'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Orçamentos',
                  icon: Icons.savings_outlined,
                  onTap: () => context.push('/budgets'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Planejado vs realizado',
                  icon: Icons.analytics_outlined,
                  onTap: () => context.push('/budget-vs-actual'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Câmbio',
                  icon: Icons.currency_exchange,
                  onTap: () => context.push('/exchange'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Importação',
                  icon: Icons.upload_file_outlined,
                  onTap: () => context.push('/imports'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Fechamento mensal',
                  icon: Icons.lock_clock_outlined,
                  onTap: () => context.push('/monthly-closures'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Regras automáticas',
                  icon: Icons.auto_fix_high_outlined,
                  onTap: () => context.push('/category-rules'),
                ),
                const SizedBox(height: 12),

                HomeMenuButton(
                  title: 'Perfil',
                  icon: Icons.person_outline,
                  onTap: () => context.push('/profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}