import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _save() async {
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      setState(() {
        _message = 'Selecione conta e categoria';
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
        amountOriginal: double.tryParse(_amountController.text) ?? 0,
        originalCurrency: _selectedCurrency,
        exchangeRate: null,
        date: _formatDate(_selectedDate),
        accountId: _selectedAccountId!,
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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar transação'),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor',
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
                    items: const [
                      DropdownMenuItem(value: 'income', child: Text('Receita')),
                      DropdownMenuItem(value: 'expense', child: Text('Despesa')),
                      DropdownMenuItem(value: 'investment', child: Text('Investimento')),
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
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
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
                      labelText: 'Moeda',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'BRL', child: Text('BRL')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'NZD', child: Text('NZD')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      DropdownMenuItem(value: 'AED', child: Text('AED')),
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    trailing: IconButton(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
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