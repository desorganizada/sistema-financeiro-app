import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'category_rule_model.dart';

class CategoryRuleService {
  Future<List<CategoryRuleModel>> getRules() async {
    try {
      final response = await DioClient.dio.get('/category-rules');

      return (response.data as List)
          .map((item) => CategoryRuleModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar regras';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar regras');
    }
  }

  Future<void> createRule({
    required String keyword,
    required int priority,
    required int categoryId,
  }) async {
    try {
      await DioClient.dio.post(
        '/category-rules',
        data: {
          'keyword': keyword,
          'priority': priority,
          'category_id': categoryId,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao criar regra';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar regra');
    }
  }
}