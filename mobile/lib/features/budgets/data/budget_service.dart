import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'budget_model.dart';

class BudgetService {
  Future<List<BudgetModel>> getBudgets({
    required int year,
    required int month,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/budgets',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return (response.data as List)
          .map((item) => BudgetModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar orçamentos';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar orçamentos');
    }
  }

  Future<void> createBudget({
    required int year,
    required int month,
    required int categoryId,
    required double plannedAmount,
  }) async {
    try {
      await DioClient.dio.post(
        '/budgets',
        data: {
          'year': year,
          'month': month,
          'category_id': categoryId,
          'planned_amount': plannedAmount,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao criar orçamento';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar orçamento');
    }
  }

  Future<void> updateBudget({
    required int budgetId,
    required int year,
    required int month,
    required int categoryId,
    required double plannedAmount,
  }) async {
    try {
      await DioClient.dio.put(
        '/budgets/$budgetId',
        data: {
          'year': year,
          'month': month,
          'category_id': categoryId,
          'planned_amount': plannedAmount,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao atualizar orçamento';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar orçamento');
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      await DioClient.dio.delete('/budgets/$budgetId');
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao excluir orçamento';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao excluir orçamento');
    }
  }
}