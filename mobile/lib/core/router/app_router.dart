import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/initial_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/dashboard/presentation/dashboard_by_category_page.dart';
import '../../features/dashboard/presentation/monthly_evolution_page.dart';
import '../../features/accounts/presentation/accounts_page.dart';
import '../../features/accounts/presentation/create_account_page.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/categories/presentation/create_category_page.dart';
import '../../features/transactions/presentation/transactions_page.dart';
import '../../features/transactions/presentation/create_transaction_page.dart';
import '../../features/transactions/presentation/edit_transaction_page.dart';
import '../../features/transactions/data/transaction_model.dart';
import '../../features/budgets/presentation/budgets_page.dart';
import '../../features/budgets/presentation/create_budget_page.dart';
import '../../features/dashboard/presentation/budget_vs_actual_page.dart';
import '../../features/exchange/presentation/exchange_rates_page.dart';
import '../../features/exchange/presentation/create_exchange_rate_page.dart';
import '../../features/exchange/presentation/convert_currency_page.dart';
import '../../features/imports/presentation/import_page.dart';
import '../../features/monthly_closures/presentation/monthly_closure_page.dart';
import '../../features/category_rules/presentation/category_rules_page.dart';
import '../../features/category_rules/presentation/create_category_rule_page.dart';
import '../../features/accounts/presentation/edit_account_page.dart';
import '../../features/accounts/data/account_model.dart';
import '../../features/categories/presentation/edit_category_page.dart';
import '../../features/categories/data/category_model.dart';
import '../../features/budgets/presentation/edit_budget_page.dart';
import '../../features/budgets/data/budget_model.dart';
import '../../features/exchange/presentation/sync_exchange_rate_page.dart';
import '../../features/dashboard/presentation/dashboard_analytics_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/base_currency_page.dart';
import '../../features/admin/presentation/admin_users_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const InitialPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/base-currency',
        builder: (context, state) => const BaseCurrencyPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/budget-vs-actual',
        builder: (context, state) => const BudgetVsActualPage(),
      ),
      GoRoute(
        path: '/dashboard-by-category',
        builder: (context, state) => const DashboardByCategoryPage(),
      ),
      GoRoute(
        path: '/dashboard-analytics',
        builder: (context, state) => const DashboardAnalyticsPage(),
      ),
      GoRoute(
        path: '/monthly-evolution',
        builder: (context, state) => const MonthlyEvolutionPage(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsPage(),
      ),
      GoRoute(
        path: '/accounts/create',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/accounts/edit',
        builder: (context, state) {
          final account = state.extra as AccountModel;
          return EditAccountPage(account: account);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/categories/create',
        builder: (context, state) => const CreateCategoryPage(),
      ),
      GoRoute(
        path: '/categories/edit',
        builder: (context, state) {
          final category = state.extra as CategoryModel;
          return EditCategoryPage(category: category);
        },
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: '/transactions/create',
        builder: (context, state) => const CreateTransactionPage(),
      ),
      GoRoute(
        path: '/transactions/edit',
        builder: (context, state) {
          final transaction = state.extra as TransactionModel;
          return EditTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/exchange',
        builder: (context, state) => const ExchangeRatesPage(),
      ),
      GoRoute(
        path: '/exchange/create',
        builder: (context, state) => const CreateExchangeRatePage(),
      ),
      GoRoute(
        path: '/exchange/convert',
        builder: (context, state) => const ConvertCurrencyPage(),
      ),
      GoRoute(
        path: '/exchange/sync',
        builder: (context, state) => const SyncExchangeRatePage(),
      ),
      GoRoute(
        path: '/imports',
        builder: (context, state) => const ImportPage(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsPage(),
      ),
      GoRoute(
        path: '/budgets/edit',
        builder: (context, state) {
          final budget = state.extra as BudgetModel;
          return EditBudgetPage(budget: budget);
        },
      ),
      GoRoute(
        path: '/budgets/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CreateBudgetPage(
            year: extra['year'],
            month: extra['month'],
          );
        },
      ),
      GoRoute(
        path: '/category-rules',
        builder: (context, state) => const CategoryRulesPage(),
      ),
      GoRoute(
        path: '/category-rules/create',
        builder: (context, state) => const CreateCategoryRulePage(),
      ),
      GoRoute(
        path: '/monthly-closures',
        builder: (context, state) => const MonthlyClosurePage(),
      ),
    ],
  );
}