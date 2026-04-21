import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../accounts/data/account_model.dart';
import '../../accounts/data/account_service.dart';
import '../../categories/data/category_model.dart';
import '../../categories/data/category_service.dart';
import '../data/import_result_model.dart';
import '../data/import_service.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final ImportService _importService = ImportService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;

  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _message;
  ImportResultModel? _result;

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

  Future<File?> _pickFile(List<String> allowedExtensions) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  Future<void> _importCsv() async {
    setState(() {
      _message = null;
      _result = null;
    });

    final file = await _pickFile(['csv']);
    if (file == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _importService.importCsv(file);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importOfx() async {
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      setState(() {
        _message = 'Selecione conta e categoria para importar OFX';
      });
      return;
    }

    setState(() {
      _message = null;
      _result = null;
    });

    final file = await _pickFile(['ofx']);
    if (file == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _importService.importOfx(
        file: file,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
      );
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResult() {
    if (_result == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Criadas: ${_result!.createdCount}'),
            Text('Ignoradas: ${_result!.skippedCount}'),
            Text('Erros: ${_result!.errorsCount}'),
            if (_result!.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Detalhes dos erros:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._result!.errors.map(
                (error) => Text(
                  '- $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
        title: const Text('Importação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Importação CSV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _importCsv,
                child: const Text('Selecionar CSV'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Importação OFX',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                labelText: 'Categoria padrão',
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _importOfx,
                child: const Text('Selecionar OFX'),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(color: Colors.red),
              ),
            _buildResult(),
          ],
        ),
      ),
    );
  }
}