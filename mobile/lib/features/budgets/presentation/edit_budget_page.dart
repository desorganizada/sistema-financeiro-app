import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/budget_model.dart';
import '../data/budget_service.dart';

class EditBudgetPage extends StatefulWidget {
  final BudgetModel budget;

  const EditBudgetPage({
    super.key,
    required this.budget,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
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
    _plannedAmountController.text = widget.budget.plannedAmount.toString();
    _selectedCategoryId = widget.budget.categoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final categories = await _categoryService.getCategories();

      final expenseAndInvestment = categories
          .where((c) => c.type == 'expense' || c.type == 'investment')
          .toList();

      setState(() {
        _categories = expenseAndInvestment;

        final exists = _categories.any((c) => c.id == _selectedCategoryId);
        if (!exists && _categories.isNotEmpty) {
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
      await _budgetService.updateBudget(
        budgetId: widget.budget.id,
        year: widget.budget.year,
        month: widget.budget.month,
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir orçamento'),
          content: const Text('Tem certeza que deseja excluir este orçamento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _budgetService.deleteBudget(widget.budget.id);

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
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar orçamento ${widget.budget.month}/${widget.budget.year}'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _delete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
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
                    : const Text('Salvar alterações'),
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