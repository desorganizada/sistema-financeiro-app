import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'currency_conversion_model.dart';
import 'exchange_rate_model.dart';

class ExchangeService {
  Future<List<ExchangeRateModel>> getExchangeRates({
    String? fromCurrency,
    String? toCurrency,
    String? rateDate,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/exchange-rates/',
        queryParameters: {
          if (fromCurrency != null && fromCurrency.isNotEmpty)
            'from_currency': fromCurrency,
          if (toCurrency != null && toCurrency.isNotEmpty)
            'to_currency': toCurrency,
          if (rateDate != null && rateDate.isNotEmpty) 'rate_date': rateDate,
        },
      );

      return (response.data as List)
          .map((item) => ExchangeRateModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar cotações';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar cotações');
    }
  }

  Future<void> createExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    required String rateDate,
  }) async {
    try {
      await DioClient.dio.post(
        '/exchange-rates/',
        data: {
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'rate': rate,
          'rate_date': rateDate,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao criar cotação';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar cotação');
    }
  }

  Future<void> syncExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    String? rateDate,
  }) async {
    try {
      await DioClient.dio.post(
        '/exchange-rates/sync',
        data: {
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          if (rateDate != null && rateDate.isNotEmpty) 'rate_date': rateDate,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao sincronizar cotação';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao sincronizar cotação');
    }
  }

  Future<CurrencyConversionModel> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    String? rateDate,
    bool autoSync = true,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/exchange-rates/convert',
        data: {
          'amount': amount,
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          if (rateDate != null && rateDate.isNotEmpty) 'rate_date': rateDate,
          'auto_sync': autoSync,
        },
      );

      return CurrencyConversionModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao converter moeda';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao converter moeda');
    }
  }
}