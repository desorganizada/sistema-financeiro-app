import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/account_model.dart';
import '../data/account_service.dart';

class EditAccountPage extends StatefulWidget {
  final AccountModel account;

  const EditAccountPage({
    super.key,
    required this.account,
  });

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  final AccountService _accountService = AccountService();

  late String _selectedType;
  late String _selectedCurrency;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.account.name;
    _initialBalanceController.text = widget.account.initialBalance.toString();
    _selectedType = widget.account.type;
    _selectedCurrency = widget.account.currency;
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _accountService.updateAccount(
        accountId: widget.account.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: double.tryParse(_initialBalanceController.text) ?? 0,
        initialBalanceDate: widget.account.initialBalanceDate,
      );

      if (!mounted) return;
      context.pop(true);
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
          title: const Text('Excluir conta'),
          content: const Text('Tem certeza que deseja excluir esta conta?'),
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
      await _accountService.deleteAccount(widget.account.id);

      if (!mounted) return;
      context.pop(true);
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
        title: const Text('Editar conta'),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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