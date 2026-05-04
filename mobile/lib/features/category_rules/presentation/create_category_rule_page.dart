import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/category_rule_service.dart';

class CreateCategoryRulePage extends StatefulWidget {
  const CreateCategoryRulePage({super.key});

  @override
  State<CreateCategoryRulePage> createState() => _CreateCategoryRulePageState();
}

class _CreateCategoryRulePageState extends State<CreateCategoryRulePage> {
  final _keywordController = TextEditingController();
  final _priorityController = TextEditingController(text: '0');

  final CategoryRuleService _ruleService = CategoryRuleService();
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;

  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final categories = await _categoryService.getCategories();

      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) {
      setState(() {
        _message = 'Selecione uma categoria';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _ruleService.createRule(
        keyword: _keywordController.text.trim(),
        priority: int.tryParse(_priorityController.text) ?? 0,
        categoryId: _selectedCategoryId!,
      );

      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova regra automática'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Palavra-chave',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}