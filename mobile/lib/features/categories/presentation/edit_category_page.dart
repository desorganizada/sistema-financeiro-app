import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
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
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _message = 'Informe o nome da categoria';
      });
      return;
    }

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Categoria atualizada com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Categoria excluída com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
      DropdownMenuItem(value: 'income', child: Text('💰 Receita')),
      DropdownMenuItem(value: 'expense', child: Text('💸 Despesa')),
      DropdownMenuItem(value: 'investment', child: Text('📈 Investimento')),
    ];
  }

  List<DropdownMenuItem<String>> _groupItems() {
    return const [
      DropdownMenuItem(value: 'fixa', child: Text('📌 Fixa')),
      DropdownMenuItem(value: 'variavel', child: Text('🔄 Variável')),
      DropdownMenuItem(value: 'extra', child: Text('✨ Extra')),
      DropdownMenuItem(value: 'adicional', child: Text('➕ Adicional')),
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
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Editar Categoria'),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _delete,
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryTerracota, AppColors.lightTerracota],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTerracota.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.category_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título
            Center(
              child: Text(
                'Editar categoria',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryTerracota,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Card do formulário
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSand,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações da categoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nome da categoria
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da categoria',
                      hintText: 'Ex: Alimentação, Salário, etc.',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tipo
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category),
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
                  
                  if (isExpense) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGroup,
                      decoration: const InputDecoration(
                        labelText: 'Grupo',
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: _groupItems(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: AppStyles.primaryButtonStyle,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar Alterações'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensagem de erro
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}