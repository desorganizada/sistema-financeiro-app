import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'dashboard_summary_model.dart';
import 'dashboard_category_model.dart';
import 'monthly_evolution_model.dart';
import 'budget_vs_actual_model.dart';

class DashboardService {
  Future<DashboardSummaryModel> getSummary({
    required int year,
    required int month,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/dashboard/summary',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return DashboardSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar resumo financeiro';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar dashboard');
    }
  }
 Future<List<BudgetVsActualModel>> getBudgetVsActual({
  required int year,
  required int month,
}) async {
  try {
    final response = await DioClient.dio.get(
      '/dashboard/budget-vs-actual',
      queryParameters: {
        'year': year,
        'month': month,
      },
    );

    return (response.data as List)
        .map((item) => BudgetVsActualModel.fromJson(item))
        .toList();
  } on DioException catch (e) {
    final message =
        e.response?.data?['detail'] ?? 'Erro ao buscar planejado vs realizado';
    throw Exception(message);
  } catch (_) {
    throw Exception('Erro inesperado ao buscar planejado vs realizado');
  }
  }
  Future<List<DashboardCategoryModel>> getByCategory({
    required int year,
    required int month,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/dashboard/by-category',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return (response.data as List)
          .map((item) => DashboardCategoryModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar categorias do dashboard';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar categorias');
    }
  }

  Future<List<MonthlyEvolutionModel>> getMonthlyEvolution({
    required int year,
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/dashboard/monthly-evolution',
        queryParameters: {
          'year': year,
        },
      );

      return (response.data as List)
          .map((item) => MonthlyEvolutionModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar evolução mensal';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar evolução mensal');
    }
  }
}