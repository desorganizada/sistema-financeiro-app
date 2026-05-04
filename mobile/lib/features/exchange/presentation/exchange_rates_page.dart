import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/exchange_rate_card.dart';
import '../data/exchange_rate_model.dart';
import '../data/exchange_service.dart';

class ExchangeRatesPage extends StatefulWidget {
  const ExchangeRatesPage({super.key});

  @override
  State<ExchangeRatesPage> createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  final ExchangeService _exchangeService = ExchangeService();

  late Future<List<ExchangeRateModel>> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  void _loadRates() {
    _ratesFuture = _exchangeService.getExchangeRates();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadRates();
    });

    await _ratesFuture;
  }

  Future<void> _goToCreate() async {
    await context.push('/exchange/create');
    await _refresh();
  }

  Future<void> _goToConvert() async {
    await context.push('/exchange/convert');
    await _refresh();
  }

  Future<void> _goToSync() async {
    await context.push('/exchange/sync');
    await _refresh();
  }

  String _formatRate(double value) {
    if (value >= 1) {
      return value.toStringAsFixed(4);
    }
    return value.toStringAsFixed(6);
  }

  String _buildReadableRate(ExchangeRateModel item) {
    return '1 ${item.fromCurrency} = ${_formatRate(item.rate)} ${item.toCurrency}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmbio'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: _goToSync,
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'convert',
            onPressed: _goToConvert,
            child: const Icon(Icons.calculate),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create',
            onPressed: _goToCreate,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<ExchangeRateModel>>(
        future: _ratesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(
              message: 'Carregando cotações...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(
                    title: 'Nenhuma cotação encontrada',
                    subtitle: 'Você pode cadastrar manualmente, sincronizar ou converter com busca automática.',
                    icon: Icons.currency_exchange,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExchangeRateCard(
                    fromCurrency: item.fromCurrency,
                    toCurrency: item.toCurrency,
                    rate: _buildReadableRate(item),
                    rateDate: item.rateDate,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}