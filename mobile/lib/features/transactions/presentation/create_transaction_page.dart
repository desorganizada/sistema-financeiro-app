import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../accounts/data/account_model.dart';
import '../../accounts/data/account_service.dart';
import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/transaction_service.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _selectedType = 'expense';
  String _selectedCurrency = 'BRL';
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final accounts = await _accountService.getAccounts();
      final categories = await _categoryService.getCategories();

      setState(() {
        _accounts = accounts;
        _categories = categories;

        if (_accounts.isNotEmpty) {
          _selectedAccountId = _accounts.first.id;
        }

        final filtered = _filteredCategories();
        if (filtered.isNotEmpty) {
          _selectedCategoryId = filtered.first.id;
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

  List<CategoryModel> _filteredCategories() {
    return _categories.where((category) => category.type == _selectedType).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // 🔧 CORREÇÃO: Converte vírgula para ponto
  double? _parseAmount(String value) {
    if (value.isEmpty) return null;
    String normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _save() async {
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      setState(() {
        _message = 'Selecione conta e categoria';
      });
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _message = 'Informe uma descrição';
      });
      return;
    }

    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _message = 'Informe um valor válido (use vírgula ou ponto)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _transactionService.createTransaction(
        description: _descriptionController.text.trim(),
        type: _selectedType,
        amountOriginal: amount,
        originalCurrency: _selectedCurrency,
        exchangeRate: null,
        date: _formatDate(_selectedDate),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transação criada com sucesso!'),
          backgroundColor: AppColors.primaryTerracota,
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories();

    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Nova Transação'),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      child: const Icon(
                        Icons.swap_horiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Text(
                      'Nova Transação',
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
                      'Registre suas movimentações financeiras',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
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
                          'Informações da transação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            hintText: 'Ex: Supermercado, Salário, etc.',
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Valor',
                            hintText: 'Ex: 100,50 ou 100.50',
                            prefixIcon: const Icon(Icons.monetization_on),
                            suffixText: _selectedCurrency,
                            suffixStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTerracota,
                            ),
                            helperText: 'Use vírgula ou ponto para decimais',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'income', child: Text('💰 Receita')),
                            DropdownMenuItem(value: 'expense', child: Text('💸 Despesa')),
                            DropdownMenuItem(value: 'investment', child: Text('📈 Investimento')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              final nextCategories = _categories
                                  .where((category) => category.type == value)
                                  .toList();

                              setState(() {
                                _selectedType = value;
                                _selectedCategoryId =
                                    nextCategories.isNotEmpty ? nextCategories.first.id : null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<int>(
                          value: _selectedAccountId,
                          decoration: const InputDecoration(
                            labelText: 'Conta',
                            prefixIcon: Icon(Icons.account_balance_wallet),
                          ),
                          items: _accounts
                              .map(
                                (account) => DropdownMenuItem<int>(
                                  value: account.id,
                                  child: Text(account.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            prefixIcon: Icon(Icons.label),
                          ),
                          items: filteredCategories
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
                        
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Moeda original',
                            prefixIcon: Icon(Icons.currency_exchange),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'BRL', child: Text('🇧🇷 Real (BRL)')),
                            DropdownMenuItem(value: 'USD', child: Text('🇺🇸 Dólar (USD)')),
                            DropdownMenuItem(value: 'EUR', child: Text('🇪🇺 Euro (EUR)')),
                            DropdownMenuItem(value: 'NZD', child: Text('🇳🇿 Dólar Neozelandês (NZD)')),
                            DropdownMenuItem(value: 'GBP', child: Text('🇬🇧 Libra (GBP)')),
                            DropdownMenuItem(value: 'AED', child: Text('🇦🇪 Dirham (AED)')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCurrency = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSand,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSand),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: AppColors.primaryTerracota),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Data',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDisplayDate(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.highlight,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.lightTerracota.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightTerracota.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.info_outline, color: AppColors.primaryTerracota, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conversão automática',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'O valor será mantido na moeda original. O dashboard mostrará o valor convertido para sua moeda base.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                          : const Text('Salvar Transação'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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