import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_service.dart';

class CreateExchangeRatePage extends StatefulWidget {
  const CreateExchangeRatePage({super.key});

  @override
  State<CreateExchangeRatePage> createState() => _CreateExchangeRatePageState();
}

class _CreateExchangeRatePageState extends State<CreateExchangeRatePage> {
  final _rateController = TextEditingController();
  final ExchangeService _exchangeService = ExchangeService();

  String _fromCurrency = 'USD';
  String _toCurrency = 'BRL';
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  String? _message;

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
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

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _exchangeService.createExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        rate: double.tryParse(_rateController.text) ?? 0,
        rateDate: _formatDate(_selectedDate),
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

  List<String> get _currencies => ['BRL', 'USD', 'EUR','NZD', 'GBP', 'AED'];

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova cotação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
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
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cotação',
                border: OutlineInputBorder(),
              ),
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