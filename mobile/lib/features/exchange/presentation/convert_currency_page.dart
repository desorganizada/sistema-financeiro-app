import 'package:flutter/material.dart';

import '../data/currency_conversion_model.dart';
import '../data/exchange_service.dart';

class ConvertCurrencyPage extends StatefulWidget {
  const ConvertCurrencyPage({super.key});

  @override
  State<ConvertCurrencyPage> createState() => _ConvertCurrencyPageState();
}

class _ConvertCurrencyPageState extends State<ConvertCurrencyPage> {
  final _amountController = TextEditingController();
  final ExchangeService _exchangeService = ExchangeService();

  String _fromCurrency = 'USD';
  String _toCurrency = 'BRL';
  CurrencyConversionModel? _result;

  bool _isLoading = false;
  String? _message;

  List<String> get _currencies => ['BRL', 'USD', 'EUR','NZD', 'GBP', 'AED'];

  Future<void> _convert() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _result = null;
    });

    try {
      final result = await _exchangeService.convertCurrency(
        amount: double.tryParse(_amountController.text) ?? 0,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _fmt(double value) => value.toStringAsFixed(2);
  String _fmtRate(double value) => value.toStringAsFixed(6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter moeda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
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
              value: _fromCurrency,
              decoration: const InputDecoration(
                labelText: 'Moeda origem',
                border: OutlineInputBorder(),
              ),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _fromCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _toCurrency,
              decoration: const InputDecoration(
                labelText: 'Moeda destino',
                border: OutlineInputBorder(),
              ),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _toCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _convert,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Converter'),
              ),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Origem: ${_fmt(_result!.amount)} ${_result!.fromCurrency}'),
                      const SizedBox(height: 8),
                      Text('Destino: ${_fmt(_result!.convertedAmount)} ${_result!.toCurrency}'),
                      const SizedBox(height: 8),
                      Text('Cotação: ${_fmtRate(_result!.exchangeRate)}'),
                      const SizedBox(height: 8),
                      Text('Data usada: ${_result!.rateDateUsed}'),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}