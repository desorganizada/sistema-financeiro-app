import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/account_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');

  final AccountService _accountService = AccountService();

  String _selectedType = 'corrente';
  String _selectedCurrency = 'BRL';
  bool _isLoading = false;
  String? _message;

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _accountService.createAccount(
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: double.tryParse(_initialBalanceController.text) ?? 0,
        initialBalanceDate: null,
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
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da conta',
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
                DropdownMenuItem(value: 'corrente', child: Text('Corrente')),
                DropdownMenuItem(value: 'carteira', child: Text('Carteira')),
                DropdownMenuItem(value: 'cartao', child: Text('Cartão')),
                DropdownMenuItem(value: 'investimento', child: Text('Investimento')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
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
            TextField(
              controller: _initialBalanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Saldo inicial',
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