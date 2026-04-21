import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/category_rule_card.dart';
import '../data/category_rule_model.dart';
import '../data/category_rule_service.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';

class CategoryRulesPage extends StatefulWidget {
  const CategoryRulesPage({super.key});

  @override
  State<CategoryRulesPage> createState() => _CategoryRulesPageState();
}

class _CategoryRulesPageState extends State<CategoryRulesPage> {
  final CategoryRuleService _service = CategoryRuleService();

  late Future<List<CategoryRuleModel>> _rulesFuture;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  void _loadRules() {
    _rulesFuture = _service.getRules();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadRules();
    });

    await _rulesFuture;
  }

  Future<void> _goToCreateRule() async {
    await context.push('/category-rules/create');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regras automáticas'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateRule,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<CategoryRuleModel>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando regras automáticas...',
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
                    title: 'Nenhuma regra cadastrada',
                    subtitle: 'Crie regras para categorizar transações automaticamente.',
                    icon: Icons.rule_folder_outlined,
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

                return CategoryRuleCard(
                  keyword: item.keyword,
                  priority: item.priority,
                  categoryId: item.categoryId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}