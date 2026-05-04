import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/data/user_model.dart';

class BaseCurrencyPage extends StatefulWidget {
  const BaseCurrencyPage({super.key});

  @override
  State<BaseCurrencyPage> createState() => _BaseCurrencyPageState();
}

class _BaseCurrencyPageState extends State<BaseCurrencyPage> {
  final AuthService _authService = AuthService();

  String? _selectedCurrency;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  List<String> get _currencies => ['BRL', 'USD', 'EUR', 'NZD', 'GBP', 'AED'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getMe();

      if (!mounted) return;
      setState(() {
        _selectedCurrency = user.baseCurrency;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCurrency == null) return;

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      final updatedUser = await _authService.updateBaseCurrency(
        baseCurrency: _selectedCurrency!,
      );

      if (!mounted) return;
      context.pop(updatedUser);
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _currencyLabel(String code) {
    switch (code) {
      case 'BRL':
        return 'BRL - Real Brasileiro';
      case 'USD':
        return 'USD - Dólar Americano';
      case 'EUR':
        return 'EUR - Euro';
      case 'GBP':
        return 'GBP - Libra Esterlina';
      case 'NZD':
        return 'NZD - Dólar Neozelandês';
      case 'AED':
        return 'AED - Dirham';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moeda base'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Escolha a moeda principal do sistema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essa moeda será usada como base para conversões e visualizações.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Moeda base',
                border: OutlineInputBorder(),
              ),
              items: _currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(_currencyLabel(currency)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar moeda base'),
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