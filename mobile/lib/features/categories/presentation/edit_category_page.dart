import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/category_model.dart';
import '../data/category_service.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryModel category;

  const EditCategoryPage({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _nameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  late String _selectedType;
  String? _selectedGroup;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
    _selectedType = widget.category.type;
    _selectedGroup = widget.category.groupName;
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _categoryService.updateCategory(
        categoryId: widget.category.id,
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir categoria'),
          content: const Text('Tem certeza que deseja excluir esta categoria?'),
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
      await _categoryService.deleteCategory(widget.category.id);

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == 'expense';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar categoria'),
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