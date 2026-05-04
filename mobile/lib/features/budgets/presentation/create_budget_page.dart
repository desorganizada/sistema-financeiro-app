import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/budget_service.dart';

class CreateBudgetPage extends StatefulWidget {
  final int year;
  final int month;

  const CreateBudgetPage({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final _plannedAmountController = TextEditingController();

  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;

  bool _isLoading = false;
  bool _isInitialLoading = true;
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

      final expenseAndInvestment = categories
          .where(
            (c) => c.type == 'expense' || c.type == 'investment',
          )
          .toList();

      setState(() {
        _categories = expenseAndInvestment;
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
      await _budgetService.createBudget(
        year: widget.year,
        month: widget.month,
        categoryId: _selectedCategoryId!,
        plannedAmount: double.tryParse(_plannedAmountController.text) ?? 0,
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
    _plannedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar orçamento ${widget.month}/${widget.year}'),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _plannedAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor planejado',
                      border: OutlineInputBorder(),
                    ),
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