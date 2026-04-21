import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/category_service.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _nameController = TextEditingController();

  final CategoryService _categoryService = CategoryService();

  String _selectedType = 'expense';
  String? _selectedGroup = 'variavel';
  bool _isLoading = false;
  String? _message;

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _categoryService.createCategory(
        name: _nameController.text.trim(),
        type: _selectedType,
        groupName: _selectedType == 'expense' ? _selectedGroup : null,
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
    _nameController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> _typeItems() {
    return const [
      DropdownMenuItem(value: 'income', child: Text('Receita')),
      DropdownMenuItem(value: 'expense', child: Text('Despesa')),
      DropdownMenuItem(value: 'investment', child: Text('Investimento')),
    ];
  }

  List<DropdownMenuItem<String>> _groupItems() {
    return const [
      DropdownMenuItem(value: 'fixa', child: Text('Fixa')),
      DropdownMenuItem(value: 'variavel', child: Text('Variável')),
      DropdownMenuItem(value: 'extra', child: Text('Extra')),
      DropdownMenuItem(value: 'adicional', child: Text('Adicional')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == 'expense';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: _typeItems(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;

                    if (_selectedType != 'expense') {
                      _selectedGroup = null;
                    } else {
                      _selectedGroup ??= 'variavel';
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (isExpense)
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                  border: OutlineInputBorder(),
                ),
                items: _groupItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedGroup = value;
                  });
                },
              ),
            if (isExpense) const SizedBox(height: 16),
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