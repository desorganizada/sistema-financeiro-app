import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'monthly_closure_model.dart';

class MonthlyClosureService {
  Future<MonthlyClosureModel> getClosure({
    required int year,
    required int month,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/monthly-closures',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return MonthlyClosureModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('NOT_FOUND');
      }

      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar fechamento mensal';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar fechamento mensal');
    }
  }

  Future<void> closeMonth({
    required int year,
    required int month,
  }) async {
    try {
      await DioClient.dio.post(
        '/monthly-closures/close',
        data: {
          'year': year,
          'month': month,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao fechar mês';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao fechar mês');
    }
  }

  Future<void> reopenMonth({
    required int year,
    required int month,
  }) async {
    try {
      await DioClient.dio.post(
        '/monthly-closures/reopen',
        data: {
          'year': year,
          'month': month,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao reabrir mês';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao reabrir mês');
    }
  }
}