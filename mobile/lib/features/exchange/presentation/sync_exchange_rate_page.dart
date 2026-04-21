import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_service.dart';

class SyncExchangeRatePage extends StatefulWidget {
  const SyncExchangeRatePage({super.key});

  @override
  State<SyncExchangeRatePage> createState() => _SyncExchangeRatePageState();
}

class _SyncExchangeRatePageState extends State<SyncExchangeRatePage> {
  final ExchangeService _exchangeService = ExchangeService();

  String _fromCurrency = 'USD';
  String _toCurrency = 'BRL';
  DateTime? _selectedDate;

  bool _isLoading = false;
  String? _message;

  List<String> get _currencies => ['BRL', 'USD', 'EUR','NZD', 'GBP', 'AED'];

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _sync() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _exchangeService.syncExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        rateDate: _selectedDate != null ? _formatDate(_selectedDate!) : null,
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
  Widget build(BuildContext context) {
    final dateLabel =
        _selectedDate == null ? 'Sem data (cotação atual)' : _formatDate(_selectedDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronizar cotação'),
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
            Card(
              child: ListTile(
                title: const Text('Data da cotação'),
                subtitle: Text(dateLabel),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        onPressed: _clearDate,
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sync,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sincronizar'),
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