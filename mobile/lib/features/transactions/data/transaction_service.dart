import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'transaction_list_response.dart';

class TransactionService {
  Future<TransactionListResponse> getTransactions({
    int? year,
    int? month,
    int? categoryId,
    int? accountId,
    String? type,
    int limit = 20,
    int offset = 0,
    String sortBy = 'date',
    String sortOrder = 'desc',
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/transactions/',
        queryParameters: {
          if (year != null) 'year': year,
          if (month != null) 'month': month,
          if (categoryId != null) 'category_id': categoryId,
          if (accountId != null) 'account_id': accountId,
          if (type != null && type.isNotEmpty) 'type': type,
          'limit': limit,
          'offset': offset,
          'sort_by': sortBy,
          'sort_order': sortOrder,
        },
      );

      return TransactionListResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        defaultMessage: 'Erro ao buscar transações',
      );
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar transações');
    }
  }

  Future<void> createTransaction({
    required String description,
    required String type,
    required double amountOriginal,
    required String originalCurrency,
    double? exchangeRate,
    required String date,
    required int accountId,
    required int categoryId,
  }) async {
    try {
      await DioClient.dio.post(
        '/transactions/',
        data: {
          'description': description,
          'type': type,
          'amount_original': amountOriginal,
          'original_currency': originalCurrency,
          if (exchangeRate != null) 'exchange_rate': exchangeRate,
          'date': date,
          'account_id': accountId,
          'category_id': categoryId,
        },
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        defaultMessage: 'Erro ao criar transação',
      );
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar transação');
    }
  }

  Future<void> updateTransaction({
    required int transactionId,
    required String description,
    required String type,
    required double amountOriginal,
    required String originalCurrency,
    double? exchangeRate,
    required String date,
    required int accountId,
    required int categoryId,
  }) async {
    try {
      await DioClient.dio.put(
        '/transactions/$transactionId',
        data: {
          'description': description,
          'type': type,
          'amount_original': amountOriginal,
          'original_currency': originalCurrency,
          if (exchangeRate != null) 'exchange_rate': exchangeRate,
          'date': date,
          'account_id': accountId,
          'category_id': categoryId,
        },
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        defaultMessage: 'Erro ao atualizar transação',
      );
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar transação');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await DioClient.dio.delete('/transactions/$transactionId');
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        defaultMessage: 'Erro ao excluir transação',
      );
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao excluir transação');
    }
  }

  String _extractErrorMessage(
    DioException e, {
    required String defaultMessage,
  }) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        return detail.join(', ');
      }
    }

    if (e.message != null && e.message!.trim().isNotEmpty) {
      return e.message!;
    }

    return defaultMessage;
  }
}